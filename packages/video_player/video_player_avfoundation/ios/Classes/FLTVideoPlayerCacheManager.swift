//
//  CacheManager.swift
//  video_player_avfoundation
//
//  Created by nguyen cuong on 02/03/2022.
//

import Foundation
import PINCache

@objc public class FLTVideoPlayerCacheManager: NSObject {
  
//    2000000 = 2MB
  static let mp4PredownloadSize = 2000000
  static var cache: PINCache = {
//    let cache = PINCache.shared
    let rootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
    let cache = PINCache.init(name: "HuukPINCacheShared", rootPath: rootPath)
//    3 GB (50 MB is default)
    cache.diskCache.byteLimit = 3 * 1024 * 1024 * 1024
//    cache.diskCache.ageLimit = 60 * 60 * 24 * 30 // 30 days by default
    return cache
  }()
  
  let hlsVideoPlayerCacheManager = FLTHLSVideoPlayerCacheManager()
  let otherVideoPlayerCacheManager = FLTOtherVideoPlayerCacheManager()
  
  public class var swiftSharedInstance: FLTVideoPlayerCacheManager {
    struct Singleton {
      static let instance = FLTVideoPlayerCacheManager()
    }
    return Singleton.instance
  }
  // the sharedInstance class method can be reached from ObjC
  @objc public class func sharedInstance() -> FLTVideoPlayerCacheManager {
    return FLTVideoPlayerCacheManager.swiftSharedInstance
  }
  
  @objc public func predownloadAndCache(urls: [String], shouldPreloadFirstSegment: NSNumber) {
    
    var hlsURLs = [String]()
    var otherURLs = [String]()
    urls.forEach { url in
      if url.hasSuffix(".m3u8") || url.hasSuffix(".M3U8") {
        hlsURLs.append(url)
      } else {
        otherURLs.append(url)
      }
    }
    if hlsURLs.isEmpty == false {
      hlsVideoPlayerCacheManager.predownloadAndCacheURls(urls, shouldPreloadFirstSegment: shouldPreloadFirstSegment)
    }
    if otherURLs.isEmpty == false {
      otherVideoPlayerCacheManager.predownloadAndCacheURls(otherURLs)
    }
  }
  
  @objc open func reverseProxyURL(from originURL: URL) -> URL {
    return hlsVideoPlayerCacheManager.reverseProxyURL(from: originURL)
  }
  
}
