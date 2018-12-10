import UIKit

extension UITableView {
    func dequeueReusableCell<CellClass: UITableViewCell>(
        of classType: CellClass.Type,
        for indexPath: IndexPath,
        defaultCell: UITableViewCell? = nil,
        configure: (CellClass) -> Void = { _ in }) -> UITableViewCell
    {
        let cell = dequeueReusableCell(withIdentifier: CellClass.reuseId, for: indexPath)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
            return typedCell
        }
        return defaultCell ?? cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseId, for: indexPath) as? T else {
            fatalError("Could not deque cell of type " + cellType.reuseId)
        }
        return cell
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseId) as? T else {
            fatalError("Could not deque header footer view of type " + viewType.reuseId)
        }
        return cell
    }
    
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType.self, forCellReuseIdentifier: cellType.reuseId)
    }
    
    func registerNib<T: UITableViewCell>(_ cellType: T.Type) {
        register(UINib(nibName: T.reuseId, bundle: nil), forCellReuseIdentifier: T.reuseId)
    }
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ cellType: T.Type) {
        register(cellType.self, forHeaderFooterViewReuseIdentifier: cellType.reuseId)
    }
}

extension UICollectionView {
    func dequeueReusableCell<CellClass: UICollectionViewCell>(
        of classType: CellClass.Type,
        for indexPath: IndexPath,
        defaultCell: UICollectionViewCell? = nil,
        configure: (CellClass) -> Void = { _ in }) -> UICollectionViewCell
    {
        let cell = dequeueReusableCell(withReuseIdentifier: CellClass.reuseId, for: indexPath)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
            return typedCell
        }
        return defaultCell ?? cell
    }
}
