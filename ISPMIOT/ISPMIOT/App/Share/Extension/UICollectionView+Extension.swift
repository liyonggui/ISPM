import UIKit

extension UICollectionView {
    func register(_ cellClass: UICollectionViewCell.Type) {
        register(cellClass.self, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func registerNib(for cellClass: UICollectionViewCell.Type) {
        register(cellClass.nib, forCellWithReuseIdentifier: cellClass.reuseId)
    }
    
    func registerSectionHeaderNib(for cellClass: UICollectionReusableView.Type) {
        let nib = UINib(nibName: cellClass.nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellClass.reuseId)
    }
    
    func registerSectionFooter(for cellClass: UICollectionReusableView.Type) {
        register(cellClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cellClass.reuseId)
    }
}

extension UICollectionViewCell {
    var showShadow: Bool {
        get {
            return layer.shadowOpacity == 0.0
        }
        set {
            clipsToBounds = !newValue
            layer.shadowOpacity = newValue ? 0.1 : 0.0
            layer.shadowOffset = CGSize(width: 0, height: 2.5)
            layer.shadowRadius = 1
        }
    }
}

extension UICollectionReusableView {
    
    @nonobjc static var nibName: String { return String(describing: self) }
}
