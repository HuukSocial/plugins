import Foundation
import CoreServices

protocol FLTResourceLoaderRequestDelegate: AnyObject {
  func dataRequestDidReceive(_ resourceLoaderRequest: FLTResourceLoaderRequest, _ data: Data)
  func dataRequestDidComplete(_ resourceLoaderRequest: FLTResourceLoaderRequest, _ error: Error?, _ downloadedData: Data)
  func contentInformationDidComplete(_ resourceLoaderRequest: FLTResourceLoaderRequest, _ result: Result<FLTAssetDataContentInformation, Error>)
//  func handlePendingReceviveDataModel(_ pendingReceviveDataModel: PendingReceviveDataModel)
  var pendingReceviveDataModels: [FLTPendingReceviveDataModel] { get set }
}

class FLTResourceLoaderRequest: NSObject, URLSessionDataDelegate {
  struct RequestRange {
    var start: Int64
    var end: RequestRangeEnd
    
    enum RequestRangeEnd {
      case requestTo(Int64)
      case requestToEnd
    }
  }
  
  enum RequestType {
    case contentInformation
    case dataRequest
  }
  
  struct ResponseUnExpectedError: Error { }
  
  private let loaderQueue: DispatchQueue
  
  let originalURL: URL
  let type: RequestType
  
  private var session: URLSession?
  private var dataTask: URLSessionDataTask?
  private var assetDataManager: FLTAssetDataManager?
  
  private(set) var requestRange: RequestRange?
  private(set) var response: URLResponse?
  private(set) var downloadedData: Data = Data()
  
  private(set) var isCancelled: Bool = false {
    didSet {
      if isCancelled {
        self.dataTask?.cancel()
        self.session?.invalidateAndCancel()
      }
    }
  }
  private(set) var isFinished: Bool = false {
    didSet {
      if isFinished {
        self.session?.finishTasksAndInvalidate()
      }
    }
  }
  
  weak var delegate: FLTResourceLoaderRequestDelegate?
  
  init(originalURL: URL, type: RequestType, loaderQueue: DispatchQueue, assetDataManager: FLTAssetDataManager?) {
    self.originalURL = originalURL
    self.type = type
    self.loaderQueue = loaderQueue
    self.assetDataManager = assetDataManager
    super.init()
  }
  
  func start(requestRange: RequestRange) {
    guard isCancelled == false, isFinished == false else {
      return
    }
    
    self.loaderQueue.async { [weak self] in
      guard let self = self else {
        return
      }
      
      var request = URLRequest(url: self.originalURL)
      self.requestRange = requestRange
      let start = String(requestRange.start)
      let end: String
      switch requestRange.end {
      case .requestTo(let rangeEnd):
        end = String(rangeEnd)
      case .requestToEnd:
        end = ""
      }
      
      let rangeHeader = "bytes=\(start)-\(end)"
      request.setValue(rangeHeader, forHTTPHeaderField: "Range")
      
      let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
      self.session = session
      let dataTask = session.dataTask(with: request)
      self.dataTask = dataTask
      dataTask.resume()
    }
  }
  
  func cancel() {
    self.isCancelled = true
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard self.type == .dataRequest else {
      return
    }
    
    self.loaderQueue.async {
      self.delegate?.dataRequestDidReceive(self, data)
      self.downloadedData.append(data)
    }
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    self.response = response
    completionHandler(.allow)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    self.isFinished = true
    self.loaderQueue.async { [self] in
      if self.type == .contentInformation {
        guard error == nil,
              let response = self.response as? HTTPURLResponse else {
                let responseError = error ?? ResponseUnExpectedError()
                self.delegate?.contentInformationDidComplete(self, .failure(responseError))
                return
              }
        
        let contentInformation = FLTResourceLoaderRequest.createAssetDataContentInformation(response: response)
        
        self.assetDataManager?.saveContentInformation(contentInformation)
//        print("cuong- saveContentInformation: \(contentInformation.contentLength)")
        self.delegate?.contentInformationDidComplete(self, .success(contentInformation))
      } else {
        if let offset = self.requestRange?.start, self.downloadedData.count > 0 {
          
          let saveResult = self.assetDataManager?.saveDownloadedData(self.downloadedData, offset: Int(offset))
          if saveResult == false {
            let pendingReceviveDataModel = FLTPendingReceviveDataModel(offset: Int(offset), data: self.downloadedData)
            delegate!.pendingReceviveDataModels.append(pendingReceviveDataModel)
            delegate!.pendingReceviveDataModels.sort { first, second in
              return first.offset < second.offset
            }
//            print("cuongne----")
            delegate!.pendingReceviveDataModels.forEach { model in
//              print("cuongne---- \(model.offset)  \(model.data.count)")
            }
//            print(delegate!.pendingReceviveDataModels)
//            print("cuongne----")
            
            if delegate!.pendingReceviveDataModels.count > 1 {
              var resolvedPendingReceviveDataModels = [FLTPendingReceviveDataModel]()
              for model in delegate!.pendingReceviveDataModels {
                let result = self.assetDataManager?.saveDownloadedData(model.data, offset: model.offset)
                if result == true {
                  resolvedPendingReceviveDataModels.append(model)
                }
              }
              
              resolvedPendingReceviveDataModels.forEach { model in
                if let index = delegate!.pendingReceviveDataModels.firstIndex(of: model) {
                  delegate!.pendingReceviveDataModels.remove(at: index)
                }
              }
              
            }
            
          }
        }
        self.delegate?.dataRequestDidComplete(self, error, self.downloadedData)
      }
    }
  }
  
  static func createAssetDataContentInformation(response: HTTPURLResponse) -> FLTAssetDataContentInformation {
    let contentInformation = FLTAssetDataContentInformation()
    
    if let rangeString = response.allHeaderFields["content-range"] as? String,
       let bytesString = rangeString.split(separator: "/").map({String($0)}).last,
       let bytes = Int64(bytesString) {
      contentInformation.contentLength = bytes
    }
    
    if let mimeType = response.mimeType,
       let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() {
      contentInformation.contentType = contentType as String
    }
    
    if let value = response.allHeaderFields["Accept-Ranges"] as? String,
       value == "bytes" {
      contentInformation.isByteRangeAccessSupported = true
    } else {
      contentInformation.isByteRangeAccessSupported = false
    }
    
    return contentInformation
  }
}
