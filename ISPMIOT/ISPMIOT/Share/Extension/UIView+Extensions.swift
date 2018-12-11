import UIKit

// MARK: layout
extension UIView {
    
    enum PlannerLayoutEdge {
        case top
        case left
        case right
        case bottom
        case centerX
        case centerY
    }
    
    func constrainToParent(_ edges: Set<PlannerLayoutEdge>, constant: CGFloat = 0) {
        guard let parentView = superview else { return }
        edges.forEach {
            switch $0 {
            case .top:
                topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant).isActive = true
            case .left:
                leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant).isActive = true
            case .right:
                trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -constant).isActive = true
            case .bottom:
                bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -constant).isActive = true
            case .centerX:
                centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: constant).isActive = true
            case .centerY:
                centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: constant).isActive = true
            }
        }
    }
    
    func centerOnParent() {
        guard let parentView = superview else { return }
        centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: 0).isActive = true
        centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: 0).isActive = true
    }
    
    @nonobjc static var reuseId: String { return String(describing: self) }

}

// MARK: Shadows
extension UIView {
    func addShadow(cgColor: CGColor = UIColor.black.cgColor, height: CGFloat = 2.0, radius: CGFloat = 4.0, opacity: Float = 0.12) {
        layer.shadowColor = cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
    func addGradientShadow(width: CGFloat, height: CGFloat = 5.0, backgroundColor: UIColor = .gray9, stopColor: CGColor = UIColor.gray7.cgColor, startColor: CGColor = UIColor.gray9.cgColor) {
        self.backgroundColor = backgroundColor
        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize(width: width, height: height)
        let stopColor = stopColor
        let startColor = startColor
        gradient.colors = [stopColor, startColor]
        gradient.locations = [0.0, 0.8]
        layer.addSublayer(gradient)
    }
}

// MARK: IBInspectable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            layer.borderColor = newValue.cgColor
        }
    }
}
