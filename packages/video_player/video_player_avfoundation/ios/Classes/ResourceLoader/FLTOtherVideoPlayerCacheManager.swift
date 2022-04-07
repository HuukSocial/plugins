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
  var urlProcessingCount = 0
  let urlsQueue = DispatchQueue(label: "com.huuk.social.otherVideoURLs", attributes: .concurrent)
  
  func predownloadAndCacheURls(_ urls: [String]) {
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
      if self.urlProcessingCount < self.urlProcessingMax {
        let itemAmountToFetch = self.urlProcessingMax - self.urlProcessingCount
        let pendingURLs = self.pendingURLs
        if itemAmountToFetch >= self.pendingURLs.count {
          self.pendingURLs.removeAll()
          self.urlProcessingCount = pendingURLs.count
          pendingURLs.forEach { url in
            self.fetchURL(url)
          }
        } else {
          for index in 0..<itemAmountToFetch {
            self.pendingURLs.removeFirst()
            self.urlProcessingCount += 1
            let url = pendingURLs[index]
            self.fetchURL(url)
          }
        }
      }
    })
  }
  
  func fetchURL(_ url: URL) {
    let cacheKey = FLTResourceLoader.createCacheKeyFrom(url: url.absoluteString)
    let cacheExisted = FLTVideoPlayerCacheManager.cache.containsObject(forKey: cacheKey)
    guard cacheExisted == false else {
      updateStateAndKeepFetchingURLIfNeeded()
      return
    }
    var request = URLRequest(url: url)
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Range"] = "bytes=\(0)-\(FLTVideoPlayerCacheManager.mp4PredownloadSize - 1)"
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
    task.resume()
  }
  
  
  func updateStateAndKeepFetchingURLIfNeeded() {
    urlsQueue.async(flags: .barrier, execute: { [weak self] in
      guard let self = self else { return }
      self.urlProcessingCount -= 1
      if self.pendingURLs.isEmpty == false {
        let pendingURL = self.pendingURLs.removeFirst()
        self.urlProcessingCount += 1
        self.fetchURL(pendingURL)
      }
    })
  }
}
