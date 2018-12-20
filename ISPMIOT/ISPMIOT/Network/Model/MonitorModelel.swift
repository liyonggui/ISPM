import Foundation
import SwiftyJSON

/// 项目环境对象
public struct MonitorModelel {

    public var id: String
    /// 全部之中最大
    public var max: Float
    /// 全部之中最小
    public var min: Float
    /// 天平均
    public var todayAvg: Float
    /// 月平均
    public var monthAvg: Float
    /// 年平均
    public var yearAvg: Float
    /// 天最小
    public var todayMin: Float
    /// 天最大
    public var todayMax: Float
    /// 月最小
    public var monthMin: Float
    /// u月最大
    public var monthMax: Float
    /// 年最小
    public var yearMin: Float
    /// 年最大
    public var yearMax: Float
    /// 创建时间
    public var createTime: String
    /// 更新时间
    public var updateTime: String
    /// 类型
    public var type: String
    /// 设备id
    public var deviceId: String
    /// 最新数据
    public var latestData: Float
    /// 风向
    public var windDirection: String
    /// 环境监测类型
    public var envType: EnvironmentParameterType = .pm25
    /// 类型string格式
    public var typeStr: String {
        didSet {
            switch typeStr {
            case "pm25": envType = .pm25
            case "pm10": envType = .pm10
            case "temperature": envType = .temperature
            case "humidity": envType = .humidity
            case "pressure": envType = .pressure
            case "wind_speed": envType = .windSpeed
            case "noise_level": envType = .noiseLevel
            case "wind_power": envType = .windPower
            case "TSP": envType = .tsp
            default: break
            }
        }
    }
    
    public init?(json: JSON) {
//        guard let id = json["id"].string else { return nil }
        self.id = json["id"].stringValue
        self.max = json["max"].floatValue
        self.min = json["min"].floatValue
        self.todayAvg = json["todayAvg"].floatValue
        self.monthAvg = json["monthAvg"].floatValue
        self.yearAvg = json["yearAvg"].floatValue
        self.todayMin = json["todayMin"].floatValue
        self.todayMax = json["todayMax"].floatValue
        self.monthMin = json["monthMin"].floatValue
        self.monthMax = json["monthMax"].floatValue
        self.yearMin = json["yearMin"].floatValue
        self.yearMax = json["yearMax"].floatValue
        self.createTime = json["createTime"].stringValue
        self.updateTime = json["updateTime"].stringValue
        self.type = json["type"].stringValue
        self.deviceId = json["deviceId"].stringValue
        self.typeStr = json["typeStr"].stringValue
        self.latestData = json["latestData"].floatValue
        self.windDirection = json["windDirection"].stringValue
    }
}

/// 环境参数类型
///
/// - pm25: PM2.5
/// - pm10: PM10
/// - temperature: 温度
/// - humidity: 湿度
/// - pressure: 气压
/// - windSpeed: 风速
/// - noiseLevel: 噪音
/// - windPower: 风力
/// - tsp: 总悬浮微粒
public enum EnvironmentParameterType: Int {
    case pm25 = 0
    case pm10
    case temperature
    case humidity
    case pressure
    case windSpeed
    case noiseLevel
    case windPower
    case tsp
}
