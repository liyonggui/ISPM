import UIKit

protocol ImageSettable {
    associatedtype Name: RawRepresentable
}

extension UIImage: ImageSettable {
    enum Name: String {
        case homeIcon = "home"
    }
    
    convenience init?(named name: Name) {
        self.init(named: name.rawValue)
    }
}
