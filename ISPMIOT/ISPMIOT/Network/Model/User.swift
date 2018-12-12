import Foundation
import SwiftyJSON

/// 用户d对象
public class User {
    
    public let id: String
    public var name: String
    
    public init?(json: JSON) {
        guard let id = json["id"].string,
            let name = json["name"].string else { return nil }
        
        self.id = id
        self.name = name
    }
}
