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
    return originURLProcessingMax * generatedManifestFilePerOriginURL // 35
  }
  var fetchingManifestReverseProxyURLsCount = 0
  var pendingManifestReverseProxyURLs = [URL]()
  
  var fetchingSegmentReverseProxyURLsMax: Int {
    return originURLProcessingMax
  }
  var fetchingSegmentReverseProxyURLsCount = 0
  var pendingSegmentReverseProxyURLs = [URL]()
  
  let reverseProxyURLsQueue = DispatchQueue(label: "com.huuk.social.reverseProxyURLs", attributes: .concurrent)
  let urlSession = URLSession(configuration: .default)
  
  public override init() {
    super.init()
    
    server.start(port: 6969)
  }
  
  @objc open func reverseProxyURL(from originURL: URL) -> URL {
    return server.reverseProxyURL(from: originURL)!
  }
  
  func predownloadAndCacheURls(_ urls: [String], shouldPreloadFirstSegment: NSNumber) {
    reverseProxyURLsQueue.async(flags: .barrier, execute: { [weak self] in
      guard let self = self else { return }
      let urls = urls.filter { url in
        return url.isEmpty == false
      }
      guard urls.isEmpty == false else {
        return
      }
      
      urls.forEach { url in
        self.pendingManifestReverseProxyURLs.append(contentsOf: self.getAllManifestReverseProxyURLs(from: url))
      }
//      print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
      if self.fetchingManifestReverseProxyURLsCount < self.fetchingManifestReverseProxyURLsMax {
        let itemAmountToFetch = self.fetchingManifestReverseProxyURLsMax - self.fetchingManifestReverseProxyURLsCount
        let pendingManifestReverseProxyURLs = self.pendingManifestReverseProxyURLs
        if itemAmountToFetch >= self.pendingManifestReverseProxyURLs.count {
          self.pendingManifestReverseProxyURLs.removeAll()
//          print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
          self.fetchingManifestReverseProxyURLsCount = pendingManifestReverseProxyURLs.count
          pendingManifestReverseProxyURLs.forEach { url in
            self.fetchManifestReverseProxyURL(url)
          }
        } else {
          for index in 0..<itemAmountToFetch {
            self.pendingManifestReverseProxyURLs.removeFirst()
//            print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
            self.fetchingManifestReverseProxyURLsCount += 1
            let url = pendingManifestReverseProxyURLs[index]
            let task = self.urlSession.dataTask(with: url) { data, response, error in
              self.fetchManifestReverseProxyURL(url)
            }
            task.resume()
          }
        }
      }
      
      
      if shouldPreloadFirstSegment == true {
        self.pendingSegmentReverseProxyURLs.append(contentsOf: urls.map { url in
          return self.getFirstSegmentURL(from: url)
        })
//        print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
        if self.fetchingSegmentReverseProxyURLsCount < self.fetchingSegmentReverseProxyURLsMax {
          let itemAmountToFetch = self.fetchingSegmentReverseProxyURLsMax - self.fetchingSegmentReverseProxyURLsCount
          let pendingSegmentReverseProxyURLs = self.pendingSegmentReverseProxyURLs
          if itemAmountToFetch >= self.pendingSegmentReverseProxyURLs.count {
            self.pendingSegmentReverseProxyURLs.removeAll()
//            print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
            self.fetchingSegmentReverseProxyURLsCount = pendingSegmentReverseProxyURLs.count
            pendingSegmentReverseProxyURLs.forEach { url in
              self.fetchSegmentReverseProxyURL(url)
            }
          } else {
            for index in 0...itemAmountToFetch {
              self.pendingSegmentReverseProxyURLs.removeFirst()
//              print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
              self.fetchingSegmentReverseProxyURLsCount += 1
              let url = pendingSegmentReverseProxyURLs[index]
              let task = self.urlSession.dataTask(with: url) { data, response, error in
                self.fetchSegmentReverseProxyURL(url)
              }
              task.resume()
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
  
  func fetchManifestReverseProxyURL(_ url: URL) {
    let task = urlSession.dataTask(with: url) { data, response, error in
      self.reverseProxyURLsQueue.async(flags: .barrier, execute: { [weak self] in
        guard let self = self else { return }
//        print("cuong: Manifest " + String(self.pendingManifestReverseProxyURLs.count))
        self.fetchingManifestReverseProxyURLsCount -= 1
        if self.pendingManifestReverseProxyURLs.isEmpty == false {
          let pendingURL = self.pendingManifestReverseProxyURLs.removeFirst()
          self.fetchingManifestReverseProxyURLsCount += 1
          self.fetchManifestReverseProxyURL(pendingURL)
        }
      })
    }
    task.resume()
  }
  
  func fetchSegmentReverseProxyURL(_ url: URL) {
    let task = urlSession.dataTask(with: url) { data, response, error in
      self.reverseProxyURLsQueue.async(flags: .barrier, execute: { [weak self] in
        guard let self = self else { return }
//        print("cuong: Segment " + String(self.pendingSegmentReverseProxyURLs.count))
        self.fetchingSegmentReverseProxyURLsCount -= 1
        if self.pendingSegmentReverseProxyURLs.isEmpty == false {
          let pendingURL = self.pendingSegmentReverseProxyURLs.removeFirst()
          self.fetchingSegmentReverseProxyURLsCount += 1
          self.fetchSegmentReverseProxyURL(pendingURL)
        }
      })
    }
    task.resume()
  }
}
