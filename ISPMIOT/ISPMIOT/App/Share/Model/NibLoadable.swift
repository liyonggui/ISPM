import UIKit

protocol NibLoadable: class {
    @nonobjc static var nibName: String { get }
}

extension NibLoadable {
    @nonobjc static var nibName: String {
        return String(describing: self)
    }
}

extension NibLoadable where Self: UIView {
    @nonobjc static var nibName: String { return String(describing: self) }
    
    @nonobjc static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func loadFromNib(frame: CGRect? = nil) -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        if let frame = frame { view.frame = frame }
        return view
    }
}

extension NibLoadable where Self: UIViewController {
    static func initFromNib() -> Self {
        return Self(nibName: nibName, bundle: nil)
    }
}

extension UIViewController: NibLoadable {}
extension UICollectionViewCell: NibLoadable {}
