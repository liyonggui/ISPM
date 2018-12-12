import Foundation
import CoreLocation
import SwiftyJSON

public struct UserService: Service {
    
    public func get() -> Future<User> {
//        ?type=top&key=11a2ef90f61e73a057a31013c2be452c

//        let request = ServiceRequest(path: "index/type=top", verb: .get, serviceDescription: self.serviceDescription)
        
        let request = ServiceRequest(
            path: "/login",
            verb: .post,
            serviceDescription: serviceDescription,
            httpBody: .jsonObject(["username": "admin", "password": "admin"])
        )
        
        return client.performJSONRequest(request).map { v -> Try<User> in
            print("asdfsfsdfsd")
            print(v)
            guard let latitude = v["lat"].double,
                let longitude = v["lng"].double else {
                    return .failure(NSError(domain: "No valid user record in data", code: HTTPError.unreadableFormat.rawValue, userInfo: .none))
            }
            var v = v
            v["lat"] = JSON(latitude)
            v["lng"] = JSON(longitude)
            guard let city = User(json: v) else {
                return .failure(NSError(domain: "No valid user record in data", code: HTTPError.unreadableFormat.rawValue, userInfo: .none))
            }
            return .success(city)
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
                                                        persistentUrlParams: .phpStyle(["apikey": "opj"]))
            
            self.init(client: client, serviceDescription: serviceDescription)
            
        default:
            self.init()
        }
    }
    
    public init(client: HTTPClient, serviceDescription: ServiceDescription) {
        self.client = client
        self.serviceDescription = serviceDescription
    }
}
