import AVFoundation
import Foundation

@objc public class FLTCachingAVURLAsset: AVURLAsset {
  
  @objc public class func create(url: URL) -> FLTCachingAVURLAsset {
    return FLTCachingAVURLAsset(url: url)
  }
  
  static let customScheme = "cachingPlayerItemScheme"
  let originalURL: URL
  private var _resourceLoader: FLTResourceLoader?
  
  static func isSchemeSupport(_ url: URL) -> Bool {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return false
    }
    
    return ["http", "https"].contains(components.scheme)
  }
  
  override init(url URL: URL, options: [String: Any]? = nil) {
    self.originalURL = URL
    
    guard var components = URLComponents(url: URL, resolvingAgainstBaseURL: false) else {
      super.init(url: URL, options: options)
      return
    }
    
    components.scheme = FLTCachingAVURLAsset.customScheme
    guard let url = components.url else {
      super.init(url: URL, options: options)
      return
    }
    
    super.init(url: url, options: options)
    
    let resourceLoader = FLTResourceLoader(asset: self)
    self.resourceLoader.setDelegate(resourceLoader, queue: FLTResourceLoader.loaderQueue)
    self._resourceLoader = resourceLoader
  }
}
