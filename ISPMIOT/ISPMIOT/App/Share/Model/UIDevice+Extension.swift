import UIKit

extension UIDevice {
    @objc class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class func isPadPro() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad,
            UIScreen.main.bounds.size.height == 1366 {
            return true
        }
        return false
    }
    
    class func is_iPhone4() -> Bool {
        return UIScreen.main.bounds.size.height == 480
    }
    
    class func is_iPhone5() -> Bool {
        return UIScreen.main.bounds.size.height == 568
    }
    
    class func is_iPhone6() -> Bool {
        return UIScreen.main.bounds.size.height == 667
    }
    
    class func is6Plus() -> Bool {
        return UIScreen.main.bounds.size.height == 736
    }
    
    class var is_iPhoneX: Bool {
        return UIScreen.main.bounds.size.height == 812
    }
    
    class func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    class func isPortrait() -> Bool {
        return UIDevice.current.orientation.isPortrait
    }
    
    @nonobjc class var currentDeviceSize: DeviceSize {
        if UIDevice.is_iPhone4() {
            return .iPhone4
        } else if UIDevice.is_iPhone5() {
            return .iPhone5
        } else if UIDevice.is_iPhone6() {
            return .iPhone6
        } else if UIDevice.is6Plus() {
            return .iPhone6Plus
        } else if UIDevice.is_iPhoneX {
            return .iPhoneX
        } else if UIDevice.isPadPro() {
            return .iPadPro
        } else if UIDevice.isPad() {
            return .iPadStd
        }
        
        return .iPhone6
    }
    
    enum DeviceSize {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneX
        case iPadStd
        case iPadPro
    }
    
    public enum Model: String {
        case simulator = "simulator/sandbox",
        iPod1          = "iPod 1",
        iPod2          = "iPod 2",
        iPod3          = "iPod 3",
        iPod4          = "iPod 4",
        iPod5          = "iPod 5",
        iPad2          = "iPad 2",
        iPad3          = "iPad 3",
        iPad4          = "iPad 4",
        iPhone4        = "iPhone 4",
        iPhone4S       = "iPhone 4S",
        iPhone5        = "iPhone 5",
        iPhone5S       = "iPhone 5S",
        iPhone5C       = "iPhone 5C",
        iPadMini1      = "iPad Mini 1",
        iPadMini2      = "iPad Mini 2",
        iPadMini3      = "iPad Mini 3",
        iPadAir1       = "iPad Air 1",
        iPadAir2       = "iPad Air 2",
        iPhone6        = "iPhone 6",
        iPhone6plus    = "iPhone 6 Plus",
        iPhone6S       = "iPhone 6S",
        iPhone6Splus   = "iPhone 6S Plus",
        unrecognized   = "?unrecognized?"
    }
    
    public var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) { $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            ptr in String(validatingUTF8: ptr)}
        }
        
        return String(validatingUTF8: modelCode!)!
    }
    
    public var type: Model {
        var modelMap: [String: Model] = [
            "i386": .simulator,
            "x86_64": .simulator,
            "iPod1,1": .iPod1,
            "iPod2,1": .iPod2,
            "iPod3,1": .iPod3,
            "iPod4,1": .iPod4,
            "iPod5,1": .iPod5,
            "iPad2,1": .iPad2,
            "iPad2,2": .iPad2,
            "iPad2,3": .iPad2,
            "iPad2,4": .iPad2,
            "iPad2,5": .iPadMini1,
            "iPad2,6": .iPadMini1,
            "iPad2,7": .iPadMini1,
            "iPhone3,1": .iPhone4,
            "iPhone3,2": .iPhone4,
            "iPhone3,3": .iPhone4,
            "iPhone4,1": .iPhone4S,
            "iPhone5,1": .iPhone5,
            "iPhone5,2": .iPhone5,
            "iPhone5,3": .iPhone5C,
            "iPhone5,4": .iPhone5C,
            "iPad3,1": .iPad3,
            "iPad3,2": .iPad3,
            "iPad3,3": .iPad3,
            "iPad3,4": .iPad4,
            "iPad3,5": .iPad4,
            "iPad3,6": .iPad4,
            "iPhone6,1": .iPhone5S,
            "iPhone6,2": .iPhone5S,
            "iPad4,1": .iPadAir1,
            "iPad4,2": .iPadAir2,
            "iPad4,4": .iPadMini2,
            "iPad4,5": .iPadMini2,
            "iPad4,6": .iPadMini2,
            "iPad4,7": .iPadMini3,
            "iPad4,8": .iPadMini3,
            "iPad4,9": .iPadMini3,
            "iPhone7,1": .iPhone6plus,
            "iPhone7,2": .iPhone6,
            "iPhone8,1": .iPhone6S,
            "iPhone8,2": .iPhone6Splus
        ]
        
        if let model = modelMap[modelIdentifier] {
            return model
        }
        return Model.unrecognized
    }
}
