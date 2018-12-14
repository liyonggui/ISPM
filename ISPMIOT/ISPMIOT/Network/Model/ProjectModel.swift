import Foundation
import SwiftyJSON

/// 项目对象
public class ProjectModel {
    
    public var id: String
    public var name: String
    public var startDate: String
    public var address: String
    public var coveredArea: String
    
    public init?(json: JSON) {
        guard let id = json["id"].string else { return nil }
        self.id = id
        self.name = json["name"].stringValue
        self.startDate = json["startDate"].stringValue
        self.address = json["address"].stringValue
        self.coveredArea = json["coveredArea"].stringValue
    }
    
//    "id": "0746f43083d940e4903a6e1a15cb49ff",
//    "name": "wzl-项目1",
//    "code": "XMXX00000013",
//    "address": "深圳市龙岗区坪地街道上坑塘",
//    "coveredArea": null,
//    "startDate": 1542384000000,
//    "endDate": null,
//    "type": "1",
//    "status": "0",
//    "start": 0,
//    "end": 0,
//    "pageCurrent": 0,
//    "pageSize": 0,
//    "pageCount": 0,
//    "orderBy": null
}
