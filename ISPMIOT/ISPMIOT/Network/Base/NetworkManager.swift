import Foundation
import SwiftyJSON
import JWT

//MARK: Public protocols
public protocol HTTPClient {
    func performJSONRequest(_ request: ServiceRequest) -> Future<JSON>
    func performJSONRequestWithResponse(_ request: ServiceRequest) -> Future<(JSON, response: HTTPURLResponse)>
    func performRequest(_ request: ServiceRequest) -> Future<(String, statusCode: Int)>
}

public protocol NetworkInitializable {
    init?(json: JSON)
}

public protocol JWTGeneratorProtocol {
    func generate() -> String
    func generate(_ payload: [String:Any]) -> String
    func generate(_ payload: [String:Any], validFor: Int) -> String
}

//MARK: Enums
public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case patch  = "PATCH"
    case put    = "PUT"
    case delete = "DELETE"
}

public enum HTTPError: NSInteger {
    case invalidURL = -255
    case invalidPathFragment = -254
    case invalidRequest = -253
    case unreadableFormat = -252
    case notAuthorized = -251
    case networkUnavailable = -250
    case serverError = -249
}

public enum URLParams: CustomDebugStringConvertible {
    case empty
    case string(String)
    case dotNetStyle([String:Any])
    case phpStyle([String:Any])
    case legacyStyle([String:Any])
    case plainStringArrayStyle([String:Any])
    case explicitPercentEncoding([URLQueryItem])

    func paramString() -> String {
        var returnString = ""
        switch self {
        case .empty:                                break
        case .phpStyle(let object):                 returnString = self.phpEncode(object)
        case .dotNetStyle(let object):              returnString = self.dotNetEncode(object)
        case .legacyStyle(let object):              returnString = self.legacyEncode(object)
        case .plainStringArrayStyle(let object):    returnString = self.plainStringArrayEncode(object)
        case .string(let string):                   returnString = string
        case .explicitPercentEncoding(let items):   return self.customPercentEncode(items)
        }

        guard let value = returnString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return ""
        }

        return value
    }

    func paramValues() -> Any {
        switch self {
        case .empty: return ""
        case .phpStyle(let object):     return object
        case .dotNetStyle(let object):  return object
        case .legacyStyle(let object):  return object
        case .plainStringArrayStyle(let object):  return object
        case .string(let string):  return string
        case .explicitPercentEncoding(let object): return object
        }
    }
    
    fileprivate func dotNetEncode(_ collection: [String:Any]) -> String {
        return collection.keys.reduce("") { accumulator, currentKey in
            if let value = collection[currentKey] as? NSArray {
                return accumulator + value.reduce("") { $0 + "\(currentKey)=\($1)&" }
            } else {
                return accumulator + "\(currentKey)=\(collection[currentKey]!)&"
            }
        }
    }
    
    fileprivate func phpEncode(_ collection: [String:Any]) -> String {
        return collection.keys.reduce("") { accumulator, currentKey in
            if let value = collection[currentKey] as? NSArray {
                return accumulator + value.reduce("") { $0 + "\(currentKey)[]=\($1)&" }
            } else {
                return accumulator + "\(currentKey)=\(collection[currentKey]!)&"
            }
        }
    }
    
    fileprivate func legacyEncode(_ collection: [String:Any]) -> String {
        let data = phpEncode(collection)

        var updatedString = data
        if let last = data.last, "&" == last {
            let newEndIndex = data.index(before: data.endIndex)
            updatedString = String(data.prefix(upTo: newEndIndex))
        }
        return updatedString
    }
    
    fileprivate func plainStringArrayEncode(_ collection: [String:Any]) -> String {
        return collection.keys.reduce("") { accumulator, currentKey in
            if let value = collection[currentKey] as? NSArray {
                // create a parameter with the format key=["value1", "value2"]

                var plainArray = value.reduce("") { $0 + "\"\($1)\","}

                if let last = plainArray.last, "," == last {
                    plainArray = String(plainArray.dropLast())
                }
                return accumulator + "\(currentKey)=[\(plainArray)]&"
            } else  if let value = collection[currentKey] as? NSString {
                return accumulator + "\(currentKey)=\"\(value)\"&"
            } else {
                return accumulator + "\(currentKey)=\(collection[currentKey]!)&"
            }
        }
    }

    fileprivate func customPercentEncode(_ collection: [URLQueryItem]) -> String {
        return collection.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
    }
    
    public var debugDescription: String { return paramString() }
}

public enum HTTPBody: CustomDebugStringConvertible {
    case empty
    case jsonObject(Any)
    case data(Foundation.Data)
    
    func bodyData() -> Foundation.Data? {
        switch self {
        case .empty: return Foundation.Data()
        case .jsonObject(let object):
            do { return try JSONSerialization.data(withJSONObject: object, options: []) }
            catch { return .none }
        case .data(let data): return data
        }
    }
    
    public var debugDescription: String {
        guard let bodyData = bodyData() else { return "<nil>" }
        return String(data: bodyData, encoding: .utf8) ?? "<cannot stringify body>"
    }
}

//MARK: Structs
public struct ServiceDescription {
    public let baseURL: URL
    public let persistentHeaders: [String:String]
    public let persistentUrlParams: URLParams
    public let jwtGenerator: JWTGeneratorProtocol?
    
    public init(baseURL: URL, persistentHeaders: [String:String], persistentUrlParams: URLParams, jwtGenerator: JWTGeneratorProtocol? = .none) {
        self.baseURL = baseURL
        self.persistentHeaders = persistentHeaders
        self.persistentUrlParams = persistentUrlParams
        self.jwtGenerator = jwtGenerator
    }
}

public struct JWTGenerator: JWTGeneratorProtocol {
    let secret: String
    let issuer: String

    public init(secret: String, issuer: String) {
        self.secret = secret
        self.issuer = issuer
    }
    
    public func generate() -> String {
        return generate([:], validFor: 10)
    }
    
    public func generate(_ payload: [String:Any]) -> String {
        return generate(payload, validFor: 10)
    }
    
    public func generate(_ payload: [String:Any], validFor: Int) -> String {
        return JWT.encode(.hs256(secret.data(using: .utf8)!)) { builder in
            for (key,value) in payload { builder[key] = value }
            builder.issuer = self.issuer
            builder.expiration = Date(timeIntervalSinceNow: 2 * 60 * 60)
        }
    }
}

public struct ServiceRequest: CustomDebugStringConvertible {
    public let path: String
    public let verb: HTTPMethod
    public let serviceDescription: ServiceDescription
    public let customHeaders: [String: String]
    public let customUrlParams: URLParams
    public let httpBody: HTTPBody

    public var debugDescription: String { return "\(verb.rawValue) url: \(serviceDescription.baseURL), resource: \(path), params: \(customUrlParams), headers: \(customHeaders)" }

    public var debugDictionary: [String: Any] {
        return ["verb": verb.rawValue,
                "url": "\(serviceDescription.baseURL)",
                "resource": path,
                "params": customUrlParams.paramValues(),
                "headers": customHeaders]
    }

    public init(path: String, verb: HTTPMethod, serviceDescription: ServiceDescription, customUrlParams: URLParams = .empty, customHeaders: [String:String] = [:], httpBody: HTTPBody = .empty) {
        self.path = path
        self.verb = verb
        self.serviceDescription = serviceDescription
        self.customHeaders = customHeaders
        self.customUrlParams = customUrlParams
        self.httpBody = httpBody
    }
}

//MARK: Extensions
extension URLSession: HTTPClient {

    public func performJSONRequest(_ request: ServiceRequest) -> Future<JSON> {
        let dataFuture = self.performDataRequest(request)
        return dataFuture.flatMap{ self.jsonForData($0.0) }
    }

    public func performJSONRequestWithResponse(_ request: ServiceRequest) -> Future<(JSON, response: HTTPURLResponse)> {
        let responseFuture = self.performDataRequestWithResponse(request)
        return responseFuture.flatMap { tuple in
            return self.jsonForData(tuple.data).map { .success(($0, response: tuple.response)) }
        }
    }
    
    public func performRequest(_ request: ServiceRequest) -> Future<(String, statusCode: Int)> {
        let mainPromise = Promise<(String, statusCode: Int)>()
        let dataFuture = self.performDataRequest(request)
        
        dataFuture.onSuccess { (data: Data, statusCode: Int) -> Void in
            guard let dataString = String(data: data, encoding: String.Encoding.utf8) else {
                reject(NSError(domain: "Invalid string content", code: HTTPError.unreadableFormat.rawValue, userInfo: .none), promise: mainPromise)
                return
            }
            resolve((dataString, statusCode), promise: mainPromise)
        }
        
        dataFuture.onFailure { (error: NSError) -> Void in
            reject(error, promise: mainPromise)
        }
        
        return mainPromise.future
    }
    
    public func performDataRequest(_ request: ServiceRequest) -> Future<(Data, statusCode: Int)> {
        let responseRequest = self.performDataRequestWithResponse(request)
        return responseRequest.map { .success(($0.data, $0.response.statusCode)) }
    }

    fileprivate func performDataRequestWithResponse(_ request: ServiceRequest) -> Future<(response: HTTPURLResponse, data: Data)> {
        let promise = Promise<(response: HTTPURLResponse, data: Data)>()

        // Compose URL
        guard let urlComponentsssss = URLComponents(url: request.serviceDescription.baseURL, resolvingAgainstBaseURL: false) else {
            reject(NSError(domain: "Invalid url", code: HTTPError.invalidURL.rawValue, userInfo: .none), promise: promise)
            return promise.future
        }
        var urlComponents = urlComponentsssss
        urlComponents.path = (request.serviceDescription.baseURL.path) + request.path

        guard var url = urlComponents.url else {
            reject(NSError(domain: "Invalid path", code: HTTPError.invalidPathFragment.rawValue, userInfo: .none), promise: promise)
            return promise.future
        }

        guard let queryAppendedURL = URL(string: url.absoluteString
            + "?"
            + request.serviceDescription.persistentUrlParams.paramString()
            + request.customUrlParams.paramString()) else {
                reject(NSError(domain: "Invalid url", code: HTTPError.invalidURL.rawValue, userInfo: .none), promise: promise)
                return promise.future
        }
        url = queryAppendedURL

        // Construct request (method and headers)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.verb.rawValue
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let headers = ["accept": "application/json", "content-type": "application/json", "applicationVersion": versionString]

        for (key, value) in (headers + request.serviceDescription.persistentHeaders) { urlRequest.setValue(value, forHTTPHeaderField: key) }
        //Insures custom headers are set last. On some devices, they were being over written.
        for (key, value) in (request.customHeaders) { urlRequest.setValue(value, forHTTPHeaderField: key) }

        // Set body data
        guard let bodyData = request.httpBody.bodyData() else {
            reject(NSError(domain: "Invalid body object", code: HTTPError.unreadableFormat.rawValue, userInfo: .none), promise: promise)
            return promise.future
        }
        urlRequest.httpBody = bodyData

        // Dispatch request
        let task = self.dataTask(with: urlRequest) {(data, response, error) in
            
            guard nil == error else {
                reject(NSError(domain: "网络连接失败", code: HTTPError.serverError.rawValue, userInfo: [NSUnderlyingErrorKey: error!]), promise: promise)
                return
            }
            let response = response as! HTTPURLResponse
            guard 200...299 ~= response.statusCode else {
                let url = response.url?.absoluteString ?? ""
                let statusAndURL =  "Server Error (\(response.statusCode) in \(url)"
                switch response.statusCode {
                case 500...599:
                    reject(NSError(domain: statusAndURL, code: HTTPError.serverError.rawValue,   userInfo: self.userInfoDictionary(data, statusCode: response.statusCode)), promise: promise)
                case 401, 403:
                    if response.url?.host == "s3.amazonaws.com" {
                        reject(NSError(domain: "网络连接失败", code: HTTPError.serverError.rawValue, userInfo: .none), promise: promise)
                        return
                    }
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didRecieve401Response")))
                    reject(NSError(domain: "没有q权限",                                code: HTTPError.notAuthorized.rawValue, userInfo: self.userInfoDictionary(data, statusCode: response.statusCode)), promise: promise)
                default:
                    reject(NSError(domain: statusAndURL, code: HTTPError.serverError.rawValue,   userInfo: self.userInfoDictionary(data, statusCode: response.statusCode)), promise: promise)
                }
                return
            }

            guard let data = data else {
                reject(NSError(domain: "Invalid data in \(response.url?.absoluteString ?? "<no url>")", code: HTTPError.unreadableFormat.rawValue, userInfo: .none), promise: promise)
                return
            }

            resolve((response, data), promise: promise)
        }

        task.resume()
        return promise.future
    }

    fileprivate func userInfoDictionary(_ data: Data?, statusCode: Int) -> [String: Any] {
        if let data = data, data.count > 0  {

            var json: [String: Any]
            do {
                json = try JSON(data: data).dictionaryObject ?? ["": ""]
            } catch {
                json = ["":""]
            }
            json["statusCode"] = statusCode
            return json
        } else {
            return ["":""]
        }
    }

    fileprivate func jsonForData(_ data: Data) -> Future<JSON> {
        let mainPromise = Promise<JSON>()

        var json =  JSON.null
        do {
            json = try JSON(data: data)
        } catch {
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                json = JSON(["data": string])
            }
        }

        guard .none == json.error else {
            reject(NSError(domain: "Invalid JSON content \(json.error?.localizedDescription ?? "with no error")", code: HTTPError.unreadableFormat.rawValue, userInfo: .none), promise: mainPromise)
            return mainPromise.future
        }

        resolve(json, promise: mainPromise)

        return mainPromise.future
    }
}

//MARK: Custom operators
private func + <KeyType, ValueType> (left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) -> Dictionary<KeyType, ValueType> {
    var result: [KeyType:ValueType] = [:]
    for (k, v) in left  { result.updateValue(v, forKey: k) }
    for (k, v) in right { result.updateValue(v, forKey: k) }
    return result
}

//MARK: Private
public func resolve<T>(_ value: T, promise: Promise<T>) {
    DispatchQueue.main.async(execute: { () -> Void in
        promise.resolve(value)
    })
}

public func reject<T>(_ error: NSError, promise: Promise<T>) {
    DispatchQueue.main.async(execute: { () -> Void in
        promise.reject(error)
    })
}
