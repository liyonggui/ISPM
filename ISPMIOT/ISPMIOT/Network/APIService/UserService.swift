import Foundation
import CoreLocation
import SwiftyJSON

public struct UserService: Service {
    
    /// 登录API
    public func login(username: String, password: String) -> Future<User> {
        let jsonBody = ["username": username, "password": password]
        let request = ServiceRequest(
            path: "/login",
            verb: .post,
            serviceDescription: serviceDescription,
            httpBody: .jsonObject(jsonBody)
        )
        
        return client.performJSONRequest(request).map { v -> Try<User> in
            MyLogLine("sdfasfasdfsa")
            MyLogLine(v)
            guard let user = User(json: v["resObject"]) else {
                return .failure(NSError(domain: v["resMessage"].stringValue, code: HTTPError.unreadableFormat.rawValue, userInfo: .none))
            }
            return .success(user)
        }
    }
    
    public var client: HTTPClient
    public var serviceDescription: ServiceDescription
    
    public init(env: Environment, applicationSource: String) {
        switch env {
        case .qa:
            let client = URLSession(configuration: URLSessionConfiguration.default)
            let serviceDescription = ServiceDescription(baseURL: APIConstant.baseURL!,
                                                        persistentHeaders: ServicesConstants.defaultHeaders(applicationSource: applicationSource),
                                                        persistentUrlParams: .empty)
//                                                        persistentUrlParams: .phpStyle(["apikey": "opj"]))
            
            self.init(client: client, serviceDescription: serviceDescription)
            
        case .production:
            let client = URLSession(configuration: URLSessionConfiguration.default)
            let serviceDescription = ServiceDescription(baseURL: APIConstant.baseURL!,
                                                        persistentHeaders: ServicesConstants.defaultHeaders(applicationSource: applicationSource),
                                                        persistentUrlParams: .empty)
//                                                        persistentUrlParams: .phpStyle(["apikey": "opj"]))
            
            self.init(client: client, serviceDescription: serviceDescription)
            
        default:
            self.init()
        }
    }
    
    public init(client: HTTPClient, serviceDescription: ServiceDescription) {
        self.client = client
        self.serviceDescription = serviceDescription
    }
    
    private var jwtHeader: [String: String] {
        return ["X-JWT": serviceDescription.jwtGenerator?.generate() ?? "JWT-NOT-GENERATED"]
    }
}
