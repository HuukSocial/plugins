//
//  FLT.swift
//  video_player_avfoundation
//
//  Created by nguyen cuong on 06/04/2022.
//

import Foundation

class FLTOtherVideoPlayerCacheManager {
  
  let urlProcessingMax = 10
  let urlSession = URLSession(configuration: .default)
  var pendingURLs = [URL]()
  var pendingHeaders = [[String: String]]()
  var urlProcessingCount = 0
  let urlsQueue = DispatchQueue(label: "com.huuk.social.otherVideoURLs", attributes: .concurrent)
  
  func predownloadAndCacheURls(_ urls: [String], headers: [[String: String]]) {
    urlsQueue.async(flags: .barrier, execute: { [weak self] in
      guard let self = self else { return }
      let urls = urls.filter { url in
        return url.isEmpty == false
      }
      guard urls.isEmpty == false else {
        return
      }
      
      self.pendingURLs.append(contentsOf: urls.map({ element in
        return URL(string: element)!
      }))
      self.pendingHeaders.append(contentsOf: headers)
      if self.urlProcessingCount < self.urlProcessingMax {
        let itemAmountToFetch = self.urlProcessingMax - self.urlProcessingCount
        let pendingURLs = self.pendingURLs
        let pendingHeaders = self.pendingHeaders
        if itemAmountToFetch >= self.pendingURLs.count {
          self.pendingURLs.removeAll()
          self.pendingHeaders.removeAll()
          self.urlProcessingCount = pendingURLs.count
          for (index, url) in pendingURLs.enumerated() {
            self.fetchURL(url, securityHeaders: pendingHeaders[index])
          }
        } else {
          for index in 0..<itemAmountToFetch {
            self.pendingURLs.removeFirst()
            self.pendingHeaders.removeFirst()
            self.urlProcessingCount += 1
            let url = pendingURLs[index]
            let headers = pendingHeaders[index]
            self.fetchURL(url, securityHeaders: headers)
          }
        }
      }
    })
  }
  
  func fetchURL(_ url: URL, securityHeaders: [String: String]) {
    let cacheKey = FLTResourceLoader.createCacheKeyFrom(url: url.absoluteString)
    let cacheExisted = FLTVideoPlayerCacheManager.cache.containsObject(forKey: cacheKey)
    guard cacheExisted == false else {
      updateStateAndKeepFetchingURLIfNeeded()
      return
    }
    var request = URLRequest(url: url)
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Range"] = "bytes=\(0)-\(FLTVideoPlayerCacheManager.mp4PredownloadSize - 1)"
    securityHeaders.forEach { (key: String, value: String) in
      headers[key] = value
    }
    request.allHTTPHeaderFields = headers
    let task = urlSession.dataTask(with: request) { data, response, error in
      guard error == nil,
            let response = response as? HTTPURLResponse,
            let data = data else { return }
      let assetData = FLTAssetData()
      assetData.contentInformation = FLTResourceLoaderRequest.createAssetDataContentInformation(response: response)
      assetData.mediaData.append(data)
      FLTResourceLoader.loaderQueue.async {
        FLTPINCacheAssetDataManager.saveAssetData(assetData, cacheKey: cacheKey)
      }
      self.updateStateAndKeepFetchingURLIfNeeded()
    }
//    print("Cuong: " + (task.currentRequest!.url!.description) + " - " + task.currentRequest!.allHTTPHeaderFields!.description)
    task.resume()
  }
  
  
  func updateStateAndKeepFetchingURLIfNeeded() {
    urlsQueue.async(flags: .barrier, execute: { [weak self] in
      guard let self = self else { return }
      self.urlProcessingCount -= 1
      if self.pendingURLs.isEmpty == false {
        let pendingURL = self.pendingURLs.removeFirst()
        let pendingHeader = self.pendingHeaders.removeFirst()
        self.urlProcessingCount += 1
        self.fetchURL(pendingURL, securityHeaders: pendingHeader)
      }
    })
  }
}
