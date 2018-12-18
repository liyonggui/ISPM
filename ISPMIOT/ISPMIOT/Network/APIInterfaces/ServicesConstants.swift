import Foundation

class ServicesConstants {
    
    static func defaultHeaders(applicationSource: String, customHeaders: [String: String]? = .none) -> [String: String] {
        var standard = ["Content-Type": "application/json",
                        "OPJIOT-APPLICATION": applicationSource]
        if let headers = customHeaders {
            for (key, value) in headers {
                standard[key] = value
            }
        }
        return standard
    }
}

/// API参数
struct APIConstant {
    static var appKey = ""
    static var baseURL = URL(string:"http://192.168.1.137:8080/app")
}
