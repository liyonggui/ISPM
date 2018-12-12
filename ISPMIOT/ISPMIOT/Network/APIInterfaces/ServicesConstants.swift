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

struct APIConstant {
//    static var baseURL = URL(string:"http://v.juhe.cn/toutiao/")
//    static var appKey = "11a2ef90f61e73a057a31013c2be452c"
    static var appKey = ""
    // http://v.juhe.cn/toutiao/index?type=top&key=11a2ef90f61e73a057a31013c2be452c
    static var baseURL = URL(string:"http://192.168.1.164/app")
}
