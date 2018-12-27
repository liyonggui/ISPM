import UIKit

/// 基类导航栏
class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .mainBackgroundBlue
        setupPan()
    }
    
    // 设置右滑返回
    private func setupPan() {
        let target = interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
        view.addGestureRecognizer(pan)
        // 禁用系统方式
        interactivePopGestureRecognizer?.isEnabled = false
        pan.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return children.count > 1
    }
}
