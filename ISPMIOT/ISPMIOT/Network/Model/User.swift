import Foundation
import SwiftyJSON

/// 用户对象
public class User {
    
//    public let id: String
    public var name: String
    public var phone: String
    
    public init?(json: JSON) {
        guard let phone = json["phone"].string else { return nil }
        self.phone = phone
        self.name = json["username"].stringValue
    }
}
