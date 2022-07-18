//
//  FLTHLSVideoPlayerCacheManager.swift
//  video_player_avfoundation
//
//  Created by nguyen cuong on 31/03/2022.
//

import Foundation
import GCDWebServer
import PINCache

class FLTHLSVideoPlayerCacheManager: NSObject {
  
  let server = FLTHLSCachingReverseProxyServer(webServer: GCDWebServer(), urlSession: URLSession(configuration: .default), cache: FLTVideoPlayerCacheManager.cache)
  
  let originURLProcessingMax = 10
  //  main.m3u8 main_1.m3u8 main_2.m3u8 main_3.m3u8 main_4.m3u8 main_5.m3u8 main_6.m3u8
  let generatedManifestFilePerOriginURL = 7
  
  var fetchingManifestReverseProxyURLsMax: Int {
    return originURLProcessingMax * generatedManifestFilePerOriginURL // 70
  }
  var fetchingManifestReverseProxyURLsCount = 0
  var pendingManifestReverseProxyURLs = [URL]()
  var pendingManifestHeaders = [[String: String]]()
  
  var fetchingSegmentReverseProxyURLsMax: Int {
    return originURLProcessingMax
  }
  var fetchingSegmentReverseProxyURLsCount = 0
  var pendingSegmentReverseProxyURLs = [URL]()
  var pendingSegmentHeaders = [[String: String]]()
  
  let reverseProxyURLsQueue = DispatchQueue(label: "com.huuk.social.reverseProxyURLs", attributes: .concurrent)
  let urlSession = URLSession(configuration: .default)
  
  public override init() {
    super.init()
    
    server.start(port: 6969)
  }
  
  @objc open func reverseProxyURL(from originURL: URL) -> URL {
    return server.reverseProxyURL(from: originURL)!
  }
  
  func predownloadAndCacheURls(_ urls: [String], shouldPreloadFirstSegment: NSNumber, headers: [[String: String]]) {
    reverseProxyURLsQueue.async(flags: .barrier, execute: { [weak self] in
      guard let self = self else { return }
      let urls = urls.filter { url in
        return url.isEmpty == false
      }
      guard urls.isEmpty == false else {
        return
      }
      
      
      for (index, url) in urls.enumerated() {
        let manifestReverseProxyURLs = self.getAllManifestReverseProxyURLs(from: url)
        self.pendingManifestReverseProxyURLs.append(contentsOf: manifestReverseProxyURLs)
        let manifestHeaders = manifestReverseProxyURLs.map { url in
          return headers[index]
        }
        self.pendingManifestHeaders.append(contentsOf: manifestHeaders)
      }
//      print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
      if self.fetchingManifestReverseProxyURLsCount < self.fetchingManifestReverseProxyURLsMax {
        let itemAmountToFetch = self.fetchingManifestReverseProxyURLsMax - self.fetchingManifestReverseProxyURLsCount
        let pendingManifestReverseProxyURLs = self.pendingManifestReverseProxyURLs
        let pendingManifestHeaders = self.pendingManifestHeaders
        if itemAmountToFetch >= self.pendingManifestReverseProxyURLs.count {
          self.pendingManifestReverseProxyURLs.removeAll()
          self.pendingManifestHeaders.removeAll()
//          print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
          self.fetchingManifestReverseProxyURLsCount = pendingManifestReverseProxyURLs.count
          for (index, url) in pendingManifestReverseProxyURLs.enumerated() {
            self.fetchManifestReverseProxyURL(url, headers: pendingManifestHeaders[index])
          }
        } else {
          for index in 0..<itemAmountToFetch {
            self.pendingManifestReverseProxyURLs.removeFirst()
            self.pendingManifestHeaders.removeFirst()
//            print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
            self.fetchingManifestReverseProxyURLsCount += 1
            let url = pendingManifestReverseProxyURLs[index]
            let headers = pendingManifestHeaders[index]
            self.fetchManifestReverseProxyURL(url, headers: headers)
          }
        }
      }
      
      
      if shouldPreloadFirstSegment == true {
        let firstSegmentURLs = urls.map { url in
          return self.getFirstSegmentURL(from: url)
        }
        self.pendingSegmentReverseProxyURLs.append(contentsOf: firstSegmentURLs)
        self.pendingSegmentHeaders.append(contentsOf: headers)
//        print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
        if self.fetchingSegmentReverseProxyURLsCount < self.fetchingSegmentReverseProxyURLsMax {
          let itemAmountToFetch = self.fetchingSegmentReverseProxyURLsMax - self.fetchingSegmentReverseProxyURLsCount
          let pendingSegmentReverseProxyURLs = self.pendingSegmentReverseProxyURLs
          let pendingSegmentHeaders = self.pendingSegmentHeaders
          if itemAmountToFetch >= self.pendingSegmentReverseProxyURLs.count {
            self.pendingSegmentReverseProxyURLs.removeAll()
            self.pendingSegmentHeaders.removeAll()
//            print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
            self.fetchingSegmentReverseProxyURLsCount = pendingSegmentReverseProxyURLs.count
            for (index, url) in pendingSegmentReverseProxyURLs.enumerated() {
              self.fetchSegmentReverseProxyURL(url, headers: pendingSegmentHeaders[index])
            }
          } else {
            for index in 0...itemAmountToFetch {
              self.pendingSegmentReverseProxyURLs.removeFirst()
              self.pendingSegmentHeaders.removeFirst()
//              print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
              self.fetchingSegmentReverseProxyURLsCount += 1
              let url = pendingSegmentReverseProxyURLs[index]
              let headers = pendingSegmentHeaders[index]
              self.fetchSegmentReverseProxyURL(url, headers: headers)
            }
          }
        }
      }
    })
  }
  
  func getFirstSegmentURL(from originURLString: String) -> URL {
    let originURL = URL(string: originURLString)!
    let absolutePathWithoutFileName = originURL.absoluteString.replacingOccurrences(of: originURL.lastPathComponent, with: "")
    let firstSegmentURL = URL(string: absolutePathWithoutFileName + "main_1_00001.ts")!
    return server.reverseProxyURL(from: firstSegmentURL)!
  }
  
  func getAllManifestReverseProxyURLs(from originURLString: String) -> [URL] {
    let originURL = URL(string: originURLString)!
    let absolutePathWithoutFileName = originURL.absoluteString.replacingOccurrences(of: originURL.lastPathComponent, with: "")
    var manifestReverseProxyURLs = [
      server.reverseProxyURL(from: originURL)!,
    ]
    for index in 1..<generatedManifestFilePerOriginURL {
      manifestReverseProxyURLs.append(server.reverseProxyURL(from: URL(string: absolutePathWithoutFileName + "main_" + String(index) + ".m3u8")!)!)
    }
    return manifestReverseProxyURLs
  }
  
  func fetchManifestReverseProxyURL(_ url: URL, headers: [String: String]) {
    var request = URLRequest(url: url)
    headers.keys.forEach { key in
      request.setValue(headers[key], forHTTPHeaderField: key)
    }
    let task = urlSession.dataTask(with: request) { data, response, error in
      self.reverseProxyURLsQueue.async(flags: .barrier, execute: { [weak self] in
        guard let self = self else { return }
//        print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
        self.fetchingManifestReverseProxyURLsCount -= 1
        if self.pendingManifestReverseProxyURLs.isEmpty == false {
          let pendingURL = self.pendingManifestReverseProxyURLs.removeFirst()
          let pendingHeaders = self.pendingManifestHeaders.removeFirst()
          self.fetchingManifestReverseProxyURLsCount += 1
          self.fetchManifestReverseProxyURL(pendingURL, headers: pendingHeaders)
        }
      })
    }
//    print("Cuong: " + (task.currentRequest!.url!.description) + " - " + task.currentRequest!.allHTTPHeaderFields!.description)
    task.resume()
  }
  
  func fetchSegmentReverseProxyURL(_ url: URL, headers: [String: String]) {
    var request = URLRequest(url: url)
    headers.keys.forEach { key in
      request.setValue(headers[key], forHTTPHeaderField: key)
    }
    let task = urlSession.dataTask(with: request) { data, response, error in
      self.reverseProxyURLsQueue.async(flags: .barrier, execute: { [weak self] in
        guard let self = self else { return }
//        print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
        self.fetchingSegmentReverseProxyURLsCount -= 1
        if self.pendingSegmentReverseProxyURLs.isEmpty == false {
          let pendingURL = self.pendingSegmentReverseProxyURLs.removeFirst()
          let pendingHeaders = self.pendingSegmentHeaders.removeFirst()
          self.fetchingSegmentReverseProxyURLsCount += 1
          self.fetchSegmentReverseProxyURL(pendingURL, headers: pendingHeaders)
        }
      })
    }
//    print("Cuong: " + (task.currentRequest!.url!.description) + " - " + task.currentRequest!.allHTTPHeaderFields!.description)
    task.resume()
  }
}
