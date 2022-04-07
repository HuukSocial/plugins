import Foundation

class FLTPendingReceviveDataModel: NSObject {
  let offset: Int
  let data: Data
  
  init(offset: Int, data: Data) {
    self.offset = offset
    self.data = data
    super.init()
  }
}
