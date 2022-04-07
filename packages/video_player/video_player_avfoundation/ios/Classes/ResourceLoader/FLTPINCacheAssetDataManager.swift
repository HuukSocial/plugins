import PINCache
import Foundation

//AssetDataManager: Extract Protocol here because other storage methods may be used to replace PINCache in the future
class FLTPINCacheAssetDataManager: NSObject, FLTAssetDataManager {
  
  let cacheKey: String
  
  init(cacheKey: String) {
    self.cacheKey = cacheKey
    super.init()
  }
  
  func saveContentInformation(_ contentInformation: FLTAssetDataContentInformation) {
    let assetData = FLTAssetData()
    assetData.contentInformation = contentInformation
    FLTVideoPlayerCacheManager.cache.setObjectAsync(assetData, forKey: cacheKey, completion: nil)
  }
  
  func saveDownloadedData(_ data: Data, offset: Int) -> Bool {
    guard let assetData = self.retrieveAssetData() else {
      return false
    }
    
//    print("cuong- \(assetData.mediaData.count) \(offset) \(data.count)")
    if let mediaData = self.mergeDownloadedDataIfIsContinuted(from: assetData.mediaData, with: data, offset: offset) {
//      print("cuong-setObjectAsync \(mediaData.count)")
      assetData.mediaData = mediaData
      FLTVideoPlayerCacheManager.cache.setObjectAsync(assetData, forKey: cacheKey, completion: nil)
      return true
    }
    return false
  }
  
  static func saveAssetData(_ assetData: FLTAssetData, cacheKey: String) {
    let oldAssetData = FLTVideoPlayerCacheManager.cache.object(forKey: cacheKey) as? FLTAssetData
    if oldAssetData != nil && oldAssetData!.mediaData.count >= assetData.mediaData.count {
      return
    }
//    print("cuong-setObjectAsync \(assetData.mediaData.count)")
    FLTVideoPlayerCacheManager.cache.setObjectAsync(assetData, forKey: cacheKey, completion: nil)
  }
  
  func retrieveAssetData() -> FLTAssetData? {
    guard let assetData = FLTVideoPlayerCacheManager.cache.object(forKey: cacheKey) as? FLTAssetData else {
      return nil
    }
    return assetData
  }
  
}

