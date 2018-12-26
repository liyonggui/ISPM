import UIKit

class BaseButton: UIButton {
    override var isEnabled: Bool {
        willSet {
            if newValue {
                backgroundColor = UIColor(red: 0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
            } else {
                backgroundColor = .lightGray
            }
        }
    }
}
