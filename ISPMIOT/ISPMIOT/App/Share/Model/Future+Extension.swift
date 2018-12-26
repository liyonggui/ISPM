import UIKit

extension Future {
    @discardableResult open func then<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        return flatMap(transform)
    }
    
    open func finally<U>(_ transform: @escaping (T) -> Future<U>) {
        return flatMap(transform).onComplete { _ in }
    }
    
    func successOrShowError(on vc: BaseViewController, withMessage errorMessage: String? = nil, _ success: @escaping (T) -> Void) {
        return self.onComplete { (t: Try<T>) in
            DispatchQueue.main.async {
                vc.view.hideActivityHUD()
            }
            switch t {
            case .success(let object): success(object)
            case .failure(let error):
                DispatchQueue.main.async {
                    guard let message = errorMessage else {
                        vc.showError(error)
                        return
                    }
                    vc.showAlert(message: message)
                }
            }
        }
    }
}
