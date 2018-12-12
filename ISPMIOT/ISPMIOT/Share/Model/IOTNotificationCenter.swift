import Foundation

// MARK: - NotificationCenterProtocol API
struct IOTNotificationCenter {
    static var defaultCenter: IOTNotificationCenterProtocol {
        get { return globalDefaultIOTNotificationCenterProtocol }
        set { globalDefaultIOTNotificationCenterProtocol = newValue }
    }
    
    static func resetDefaultCenter() {
        globalDefaultIOTNotificationCenterProtocol = IOTNotificationCenter_Private()
    }
    
    enum NotificationType: String {
        case userLoggedIn
    }
}

protocol IOTNotificationCenterProtocol {
    func addObserver(_ observer: Any, selector: Selector, notificationType: IOTNotificationCenter.NotificationType, object: Any?)
    func removeObserver(_ observer: Any, notificationType: IOTNotificationCenter.NotificationType?, object: Any?)
    func post(notificationType: IOTNotificationCenter.NotificationType, object: Any?, userInfo: [AnyHashable: Any]?)
}

// MARK: - Convenience extension because default arguments don't work with protocol types quite as we'd like
extension IOTNotificationCenterProtocol {
    func addObserver(_ observer: Any, selector: Selector, notificationType: IOTNotificationCenter.NotificationType) {
        addObserver(observer, selector: selector, notificationType: notificationType, object: .none)
    }
    
    func removeObserver(_ observer: Any) {
        removeObserver(observer, notificationType: .none, object: .none)
    }
    
    func removeObserver(_ observer: Any, notificationType: IOTNotificationCenter.NotificationType) {
        removeObserver(observer, notificationType: notificationType, object: .none)
    }
    
    func post(notificationType: IOTNotificationCenter.NotificationType) {
        post(notificationType: notificationType, object: .none, userInfo: .none)
    }
    
    func post(notificationType: IOTNotificationCenter.NotificationType, object: Any) {
        post(notificationType: notificationType, object: object, userInfo: .none)
    }
    
    func post(notificationType: IOTNotificationCenter.NotificationType, userInfo: [AnyHashable: Any]?) {
        post(notificationType: notificationType, object: .none, userInfo: userInfo)
    }
}

// MARK: - Private stuff (don't look! ಠ~ಠ)
private class IOTNotificationCenter_Private: IOTNotificationCenterProtocol {
    func addObserver(_ observer: Any, selector: Selector, notificationType: IOTNotificationCenter.NotificationType, object: Any?) {
        systemNotificationCenter.addObserver(observer, selector: selector, name: NSNotification.Name(notificationType.rawValue), object: object)
    }
    
    func removeObserver(_ observer: Any, notificationType: IOTNotificationCenter.NotificationType?, object: Any?) {
        if let type = notificationType {
            systemNotificationCenter.removeObserver(observer, name: NSNotification.Name(type.rawValue), object: object)
        } else {
            systemNotificationCenter.removeObserver(observer)
        }
    }
    
    func post(notificationType: IOTNotificationCenter.NotificationType, object: Any? = .none, userInfo: [AnyHashable: Any]?) {
        systemNotificationCenter.post(name: NSNotification.Name(notificationType.rawValue), object: object, userInfo: userInfo)
    }
}

private var globalDefaultIOTNotificationCenterProtocol: IOTNotificationCenterProtocol = IOTNotificationCenter_Private()
private var systemNotificationCenter: NotificationCenter = NotificationCenter.default
