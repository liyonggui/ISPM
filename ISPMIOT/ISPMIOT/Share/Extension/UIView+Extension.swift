import UIKit

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
}
