import UIKit

class TopViewController {
    
    static func topViewController() -> UIViewController? {
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        return self.topViewControllerWithRootViewController(root)
    }
    
    static func topViewControllerWithRootViewController(_ rootViewController: UIViewController) -> UIViewController {
        if let tabViewController = rootViewController as? UITabBarController,
            let selected = tabViewController.selectedViewController {
            return self.topViewControllerWithRootViewController(selected)
        } else if let navController = rootViewController as? UINavigationController,
            let visibleController = navController.visibleViewController {
            return self.topViewControllerWithRootViewController(visibleController)
        } else if let presentedController = rootViewController.presentedViewController {
            return self.topViewControllerWithRootViewController(presentedController)
        } else {
            return rootViewController
        }
    }
}
