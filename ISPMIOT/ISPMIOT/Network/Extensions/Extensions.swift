import Foundation
import SwiftyJSON

extension URL {
    var inHttps: URL {
        return URL(string: self.absoluteString.replacingOccurrences(of: "http:", with: "https:")) ?? self
    }
    
    func makeHttps() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = "https"
        let newUrl = components?.url
        return newUrl
    }
}

//MARK: - Service, Client, & HTTP stuff
public protocol Service {
    var client: HTTPClient { get set }
    var serviceDescription: ServiceDescription { get set }
    
    init()
    init(env: Environment, applicationSource: String)
    init(client: HTTPClient, serviceDescription: ServiceDescription)
}

//MARK: - 
public extension Service {
    public init() {
        let client = MockHTTPClient()
        let serviceDescription = ServiceDescription(baseURL: URL(string: "http://www.baidu.com/")!,// TODO: 需要更改
                                                    persistentHeaders: [:],
                                                    persistentUrlParams: .empty,
                                                    jwtGenerator: MockJWTGenerator())
        self.init(client: client, serviceDescription: serviceDescription)
    }
}

public class MockHTTPClient: HTTPClient {
    public var jsonRequests: [(request: ServiceRequest, promise: Promise<JSON>)] = []
    public var jsonResponseRequests: [(request: ServiceRequest, promise: Promise<(JSON, response: HTTPURLResponse)>)] = []
    public var stringRequests: [(request: ServiceRequest, promise: Promise<(String, statusCode: Int)>)] = []
    
    public func performJSONRequest(_ request: ServiceRequest) -> Future<JSON> {
        let promise = Promise<JSON>()
        jsonRequests.append((request: request, promise: promise))
        return promise.future
    }
    
    public func performJSONRequestWithResponse(_ request: ServiceRequest) -> Future<(JSON, response: HTTPURLResponse)> {
        let promise = Promise<(JSON, response: HTTPURLResponse)>()
        jsonResponseRequests.append((request: request, promise: promise))
        return promise.future
    }
    
    public func performRequest(_ request: ServiceRequest) -> Future<(String, statusCode: Int)> {
        let promise = Promise<(String, statusCode: Int)>()
        stringRequests.append((request: request, promise: promise))
        return promise.future
    }
}

extension MockHTTPClient {
    public func jsonRequestsForPath(path: String) -> [(request: ServiceRequest, promise: Promise<JSON>)] {
        return jsonRequests.filter { $0.request.path == path }
    }
    
    public func jsonResponseRequestsForPath(path: String) -> [(request: ServiceRequest, promise: Promise<(JSON, response: HTTPURLResponse)>)] {
        return jsonResponseRequests.filter { $0.request.path == path }
    }
    
    public func requestsForPath(path: String) -> [(request: ServiceRequest, promise: Promise<(String, statusCode: Int)>)] {
        return stringRequests.filter { $0.request.path == path }
    }
}

internal class MockJWTGenerator: JWTGeneratorProtocol {
    public func generate() -> String { return "jwt" }
    public func generate(_ payload: [String: Any] = [:]) -> String { return "jwt" }
    public func generate(_ payload: [String: Any] = [:], validFor: Int) -> String { return "jwt" }
}

extension Promise {
    static var rejectedUserPromise: Promise {
        let promise = Promise()
        let domain = "The user is not logged in"
        promise.reject(NSError(domain: domain, code: -1, userInfo: nil))
        return promise
    }
}

//MARK: - Extensions provided for testing.
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension TimeZone {
    func offsetInHours() -> String {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
}
