import Foundation

protocol FLTAssetDataManager: NSObject {
  func retrieveAssetData() -> FLTAssetData?
  func saveContentInformation(_ contentInformation: FLTAssetDataContentInformation)
  func saveDownloadedData(_ data: Data, offset: Int) -> Bool
  func mergeDownloadedDataIfIsContinuted(from: Data, with: Data, offset: Int) -> Data?
}

extension FLTAssetDataManager {
  func mergeDownloadedDataIfIsContinuted(from: Data, with: Data, offset: Int) -> Data? {
//    I only deal with merging continuous data (such as existing 0~100, the new data is 75~200, and it becomes 0~200 after merging; if the new data is 150~200, I will ignore the non-merging process
//    To deal with non-consecutive data: http://chuquan.me/2019/12/03/ios-avplayer-support-cache/
    if offset <= from.count && (offset + with.count) > from.count {
      let start = from.count - offset
      var data = from
      data.append(with.subdata(in: start..<with.count))
      return data
    }
    return nil
  }
}
