import Foundation
import SwiftyJSON

/// 项目对象
public struct ProjectModel {
    
    public var id: String
    /// 项目名称
    public var name: String
    /// 开工时间
    public var startDate: String
    /// 地址
    public var address: String
    public var coveredArea: String
    /// 业主
    public var ownerName: String
    public var ownerPhone: String
    /// 类型
    public var typeStr: String
    /// 环境参数
    public var devices: [DevicesTotalModel] = []
    /// 总数
    public var totalCount = 0
    /// 在线
    public var availableCount = 0
    /// 离线
    public var outlineCount = 0
    /// 错误
    public var unavailableCount = 0
    /// 图片
    public var images: [String] = []
    
    public init?(json: JSON) {
        guard let id = json["id"].string else { return nil }
        self.id = id
        self.name = json["name"].stringValue
        self.startDate = json["startDate"].stringValue.substring(toIndex: 10).timeStampToStrings ?? ""
        self.address = json["address"].stringValue
        self.coveredArea = json["coveredArea"].stringValue
        self.ownerName = json["ownerName"].stringValue
        self.ownerPhone = json["ownerContact"].stringValue
        self.typeStr = json["typeStr"].stringValue
        self.devices = json["deviceInfoVos"].arrayValue.compactMap { DevicesTotalModel(json: $0) }
        if !self.devices.isEmpty {// reduce(0, +) 相加
            self.totalCount = self.devices.map { $0.count }.reduce(0, +)
            self.availableCount = self.devices.map { $0.availableCount }.reduce(0, +)
            self.unavailableCount = self.devices.map { $0.unavailableCount }.reduce(0, +)
            self.outlineCount = self.devices.map { $0.outlineCount }.reduce(0, +)
        }
        // 后台返回数据 以 | 分割
        self.images = json["images"].stringValue.components(separatedBy: "|")
    }
}

/// 统计设备总数模型
public struct DevicesTotalModel {
    public var name: String
    /// 类别(1.人脸识别柱,2.视频监控,3.环境监测仪,4.塔吊,5.其它)
    public var category: String
    /// 当前页数
    public var pageCurrent: Int
    /// 总页数
    public var pageSize: Int
    /// 总数
    public var count: Int
    /// 在线
    public var availableCount: Int
    /// 离线
    public var outlineCount: Int
    /// 错误
    public var unavailableCount: Int
    
    public init?(json: JSON) {
        self.name = json["vname"].stringValue
        self.category = json["category"].stringValue
        self.pageCurrent = json["pageCurrent"].intValue
        self.pageSize = json["pageSize"].intValue
        self.count = json["count"].intValue
        self.availableCount = json["availableCount"].intValue
        self.unavailableCount = json["unavailableCount"].intValue
        self.outlineCount = json["outlineCount"].intValue
    }
    
}
