import UIKit
import JWT

/// 全局静态网络工具
public var interfaceSharedInstance: Interface!

public struct Interface {
 
    /// 创建网络请求工具Interface
    ///
    /// - Parameters:
    ///   - environment: 环境(测试qa/发布production)
    ///   - applicationSource: API标志参数
    public init(environment: Environment,
                applicationSource: String) {
        self.applicationSource = applicationSource
        self.environment = environment
        userService = UserService(env: environment, applicationSource: applicationSource)
    }
    
    // Service
    public var userService: UserService
    
    public let applicationSource: String
    public let environment: Environment
    
    public var loggedUser: User?
    
    public var token: String? {
        get {
            return UserDefaults.standard.string(forKey: kSavedUserToken)
        }
        
        set {
            if let newUser = newValue {
                UserDefaults.standard.set(newUser, forKey: kSavedUserToken)
            } else {
                UserDefaults.standard.removeObject(forKey: kSavedUserToken)
            }
        }
    }

}

// Private reference
internal let kSavedUserDataKey = "Saved User Data"
internal let kSavedUserToken = "Saved User Token"
