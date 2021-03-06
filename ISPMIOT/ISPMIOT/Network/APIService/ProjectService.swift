import Foundation
import SwiftyJSON

public struct ProjectService: Service {
    
    /// 获取环境数据
    ///
    /// - Parameter model: 传入模型
    /// - Returns: 返回模型数组
    public func getEnvMonitor(_ model: ProjectModel) -> Future<[MonitorModelel]> {
        let request = ServiceRequest(
            path: "/getEnvMonitorByPid/\(model.id)",
            verb: .post,
            serviceDescription: serviceDescription
        )
        return client.performJSONRequest(request).map { v -> Try<[MonitorModelel]> in
            guard v["resCode"] == "200" else {
                return .failure(NSError(domain: v["resMessage"].stringValue, code: HTTPError.unreadableFormat.rawValue, userInfo: .none))
            }
            return .success(v["resList"].arrayValue.compactMap { (value) in MonitorModelel(json: value) })
        }
    }
    
    /// 获取设备列表数据
    ///
    /// - Parameter model: 传入模型
    /// - Returns: 返回模型数组
    public func getDevices(_ model: ProjectModel) -> Future<[DevicesModel]> {
        let request = ServiceRequest( //02f175fc8a3548c7bd438f67ded83bbf
            path: "/getDevicesByPid/\(model.id)",
//            path: "/getDevicesByPid/02f175fc8a3548c7bd438f67ded83bbf",
            verb: .post,
            serviceDescription: serviceDescription
        )
        return client.performJSONRequest(request).map { v -> Try<[DevicesModel]> in
            guard v["resCode"] == "200" else {
                return .failure(NSError(domain: v["resMessage"].stringValue, code: HTTPError.unreadableFormat.rawValue, userInfo: .none))
            }
            return .success(v["resList"].arrayValue.compactMap { (value) in DevicesModel(json: value) })
        }
    }
        
    /// 获取项目列表
    ///
    /// - Returns: 返回模型数组
    public func getProjects() -> Future<[ProjectModel]> {
        let request = ServiceRequest(
            path: "/getProjects",
            verb: .post,
            serviceDescription: serviceDescription
        )
        
        return client.performJSONRequest(request).map { v -> Try<[ProjectModel]> in
            guard v["resCode"] == "200" else {
                return .failure(NSError(domain: v["resMessage"].stringValue, code: HTTPError.unreadableFormat.rawValue, userInfo: .none))
            }
            return .success(v["resList"].arrayValue.compactMap { (value) in ProjectModel(json: value) })
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
