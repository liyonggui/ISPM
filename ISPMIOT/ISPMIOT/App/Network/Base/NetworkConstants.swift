import Foundation

public enum ErrorCodes: Int {
    // Internet Related
    case notConnectToInternet = -1009
    
    // HTTP Error Related
    case timeout = -256
    case invalidURL = -255
    case invalidPathFragment = -254
    case invalidRequest = -253
    case unreadableFormat = -252
    case networkUnavailable = -250
    case serverError = -249
    case generic400 = 400
    case generic500 = 500
    
    // Client Side Related
    case userNotLoggedIn = 701
    case invalidData = 702
    
    public func message() -> String {
        switch self {
            // InternetConnectivity
        case .notConnectToInternet: return "Looks like you’re not connected to the internet. Get back online and try again, will ya?"
            
            // Authorization
        case .userNotLoggedIn:      return "Log in or create an account so we can get back to wedding planning."
            
            // Sever Connection Failure
        case .generic400, .generic500, .timeout, .invalidData: return "This is embarrassing... Something’s not working right. Don’t worry, we’re working on it!"

            // Defualt
        default:                    return "This is embarrassing... Something’s not working right. Don’t worry, we’re working on it!"
        }
    }
    
    public func generateError() -> NSError {
        return NSError(domain: self.message(), code: self.rawValue, userInfo: nil)
    }
}

public enum Environment {
    case qa
    case production
    case spec
}
