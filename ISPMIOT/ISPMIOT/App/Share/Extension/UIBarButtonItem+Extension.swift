import UIKit

@objc extension UIBarButtonItem {
    
    @objc enum ButtonAlign: Int {
        case right
        case left
    }
    
    @nonobjc static func blueTitle(_ title: String, target: Any, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(title: title, color: UIColor.mainTextBlue, target: target, selector: selector)
    }
    
    convenience init(title: String, color: UIColor, target: Any, selector: Selector, font: UIFont = UIFont.TisaSans.regular.sized(.small)) {
        let button = UIButton(type: .custom)
        button.addTarget(target, action: selector, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = font
        button.sizeToFit()
        if font == UIFont.TisaSans.medium.sized(.small) {
            button.contentEdgeInsets = UIEdgeInsets(top: -2, left: 0, bottom: -3, right: 0)
        }
        
        self.init(customView: button)
    }
    
    static func backButton(_ title: String?, color: UIColor = UIColor.mainTextBlue, target: Any, selector: Selector, showArrow: Bool = false) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        button.addTarget(target, action: selector, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.TisaSans.regular.sized(.regular)
        button.setTitleColor(color, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if showArrow, let image = UIImage(named: "back")?.reSizeImage(reSize: CGSize(width: 20, height: 20)) {
            button.setImage(image, for: .normal)
            button.setImage(image, for: .highlighted)
            button.imageEdgeInsets = title.isNilOrEmpty ? UIEdgeInsets(top: 1, left: -12, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        }
        return UIBarButtonItem(customView: button)
    }
        
    @nonobjc static func customButton(_ button: UIButton, target: Any, selector: Selector) -> UIBarButtonItem {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.addTarget(target, action: selector, for: .touchUpInside)
        customView.addSubview(button)
        let tap = UITapGestureRecognizer(target: target, action: selector)
        customView.addGestureRecognizer(tap)
        return UIBarButtonItem(customView: customView)
    }
    
    static func closeButton(target: Any, selector: Selector, color: UIColor = .black, align: ButtonAlign = .left) -> UIBarButtonItem {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(frame: customView.bounds)
        imageView.image = UIImage(named: "close")
        customView.addSubview(imageView)
        let tap = UITapGestureRecognizer(target: target, action: selector)
        customView.addGestureRecognizer(tap)
        return UIBarButtonItem(customView: customView)
    }
    
    @nonobjc static func iconButton(target: Any, selector: Selector, iconType: UIImage.Name) -> UIBarButtonItem {
        let iconButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        iconButton.addTarget(target, action: selector, for: .touchUpInside)
        iconButton.setImage(UIImage(named: iconType), for: .normal)
        iconButton.sizeToFit()
        iconButton.contentEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: -3, right: 0)
        return UIBarButtonItem(customView: iconButton)
    }
}
