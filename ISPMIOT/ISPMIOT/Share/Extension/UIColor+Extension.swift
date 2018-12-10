import Foundation
import UIKit

// MARK: Blues 
public extension UIColor {
    @objc public static let mainBlue = UIColor(red: 74/255, green: 180/255, blue: 229/255, alpha: 1)
    @objc public static let knotBlue = UIColor(red: 114/255, green: 202/255, blue: 242/255, alpha: 1)
}

// MARK: Grays
public extension UIColor {
    @objc public static var gray9 = UIColor(white: 244/255, alpha: 1)
    @objc public static var gray8 = UIColor(white: 229/255, alpha: 1)
    @objc public static var gray7 = UIColor(white: 204/255, alpha: 1)
    @objc public static var gray5 = UIColor(white: 156/255, alpha: 1)
    @objc public static var gray4 = UIColor(white: 120/255, alpha: 1)
    @objc public static var blackXO = UIColor(white: 35/255, alpha: 1)
    @objc public static var blueGray1 = UIColor(red: 68/255, green: 79/255, blue: 86/255, alpha: 1)
    @objc public static var blueGray2 = UIColor(red: 96/255, green: 110/255, blue: 120/255, alpha: 1)
}

// MARK: Corals
public extension UIColor {
    @objc public static var coral = UIColor(red: 230/255, green: 85/255, blue: 69/255, alpha: 1)
    @objc public static var ctaCoral = UIColor(red: 235/255, green: 119/255, blue: 106/255, alpha: 1)
    @objc public static var disabledCoral = UIColor(red: 247/255, green: 204/255, blue: 199/255, alpha: 1)
}

// MARK: Utility
public extension UIColor {
    @objc public static var errorRed = UIColor(red: 192/255, green: 4/255, blue: 4/255, alpha: 1)
    @objc public static var successGreen = UIColor(red: 29/255, green: 164/255, blue: 33/255, alpha: 1)
}

// MARK: QA / Debugging
public extension UIColor {
    @objc public static var styleGuideViolationGreen = UIColor(red: 133/255, green: 121/255, blue: 45/255, alpha: 1)
}
