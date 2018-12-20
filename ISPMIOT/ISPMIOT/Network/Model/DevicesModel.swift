import Foundation
import SwiftyJSON

/// 项目对象
public struct DevicesModel {
    /// ID
    public var id: Int
    /// 项目名称
    public var name: String
    ///
    public var manufactureDate: String
    public var productModel: String
    public var category: String
    public var status: String
    public var projectId: String
    public var projectName: String
    public var companyName: String
    public var siteNum: String
    public var ip: String
    public var pageSize: Int
    public var pageCount: Int
    public var pageCurrent: Int
    
    public init?(json: JSON) {
        guard let id = json["id"].int else { return nil }
        self.id = id
        self.name = json["vname"].stringValue
        self.manufactureDate = json["manufactureDate"].stringValue
        self.productModel = json["productModel"].stringValue
        self.category = json["category"].stringValue
        self.status = json["status"].stringValue
        self.projectId = json["projectId"].stringValue
        self.projectName = json["projectName"].stringValue
        self.companyName = json["companyName"].stringValue
        self.siteNum = json["siteNum"].stringValue
        self.ip = json["ip"].stringValue
        self.pageSize = json["pageSize"].intValue
        self.pageCount = json["pageCount"].intValue
        self.pageCurrent = json["pageCurrent"].intValue
    }
}
