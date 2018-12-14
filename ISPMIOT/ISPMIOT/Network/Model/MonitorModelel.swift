import Foundation
import SwiftyJSON

/// 项目环境对象
public class MonitorModelel {
    
    public var id: String
    public var sn: String
    public var projectId: String
    public var projectName: String
    public var humidity: Int
    public var noiseLevel: Int
    public var pm25: Int
    public var pressure: Int
    public var temperature: Int
    public var tsp: Int
    public var windDirection: String
    public var windPower: Int
    public var windSpeed: Int
    
    public init?(json: JSON) {
        guard let id = json["id"].string else { return nil }
        self.id = id
        self.sn = json["sn"].stringValue
        self.projectId = json["projectId"].stringValue
        self.projectName = json["projectName"].stringValue
        
        self.humidity = json["humidity"].intValue
        self.noiseLevel = json["noiseLevel"].intValue
        self.pm25 = json["pm25"].intValue
        self.pressure = json["pressure"].intValue
        self.temperature = json["temperature"].intValue
        self.tsp = json["tsp"].intValue
        self.windDirection = json["windDirection"].stringValue
        self.windPower = json["windPower"].intValue
        self.windSpeed = json["windSpeed"].intValue
    }
}
