import Foundation
import CryptoKit

class FLTAssetDataContentInformation: NSObject, NSCoding {
  @objc var contentLength: Int64 = 0
  @objc var contentType: String = ""
  @objc var isByteRangeAccessSupported: Bool = false
  
  func encode(with coder: NSCoder) {
    coder.encode(self.contentLength, forKey: #keyPath(FLTAssetDataContentInformation.contentLength))
    coder.encode(self.contentType, forKey: #keyPath(FLTAssetDataContentInformation.contentType))
    coder.encode(self.isByteRangeAccessSupported, forKey: #keyPath(FLTAssetDataContentInformation.isByteRangeAccessSupported))
  }
  
  override init() {
    super.init()
  }
  
  required init?(coder: NSCoder) {
    super.init()
    self.contentLength = coder.decodeInt64(forKey: #keyPath(FLTAssetDataContentInformation.contentLength))
    self.contentType = coder.decodeObject(forKey: #keyPath(FLTAssetDataContentInformation.contentType)) as? String ?? ""
    self.isByteRangeAccessSupported = coder.decodeBool(forKey: #keyPath(FLTAssetDataContentInformation.isByteRangeAccessSupported))
  }
}

//implements NSCoding, because PINCache relies on the archivedData method encode/decode
//Because the size of the Cache file for music is at most 10 MB, so PINCache can be used as a local Cache tool; if you want to serve videos, you cannot use this method (you may have to load several GB of data into memory at a time)
class FLTAssetData: NSObject, NSCoding {
  @objc var contentInformation = FLTAssetDataContentInformation()
  @objc var mediaData = Data()
  
  override init() {
    super.init()
  }
  
  func encode(with coder: NSCoder) {
    coder.encode(self.contentInformation, forKey: #keyPath(FLTAssetData.contentInformation))
    coder.encode(self.mediaData, forKey: #keyPath(FLTAssetData.mediaData))
  }
  
  required init?(coder: NSCoder) {
    super.init()
    self.contentInformation = coder.decodeObject(forKey: #keyPath(FLTAssetData.contentInformation)) as? FLTAssetDataContentInformation ?? FLTAssetDataContentInformation()
    self.mediaData = coder.decodeObject(forKey: #keyPath(FLTAssetData.mediaData)) as? Data ?? Data()
  }
}
