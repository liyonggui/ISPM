import UIKit

@objc extension UIAlertController { 
    @objc func showAnimated(_ animated: Bool, from viewController: UIViewController? = nil) {
        self.showAnimated(animated, sourceView: nil, sourceRect: nil, from: viewController)
    }
    
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { self.addAction($0) }
    }
}

extension UIAlertController {
    func showAnimated(_ animated: Bool,
                      sourceView: UIView?,
                      sourceRect: CGRect?,
                      arrowDirection: UIPopoverArrowDirection = .left,
                      from viewController: UIViewController? = nil) {
        
        if let topController = viewController ?? TopViewController.topViewController() {
            topController.present(self, animated: animated, completion: nil)
        }
    }
    
    func showAnimated(_ animated: Bool,
                      sourceRect: CGRect?,
                      arrowDirection: UIPopoverArrowDirection = .left,
                      from viewController: UIViewController? = nil) {
        self.showAnimated(animated, sourceView: nil, sourceRect: sourceRect, from: viewController)
    }
}
