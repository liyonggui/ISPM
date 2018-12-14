import Foundation
import SwiftyJSON

/// 项目对象
public class ProjectModel {
    
    public var id: String
    public var name: String
    public var startDate: String
    
    public init?(json: JSON) {
        guard let id = json["id"].string else { return nil }
        self.id = id
        self.name = json["name"].stringValue
        self.startDate = json["startDate"].stringValue
    }
}
