import UIKit

/// 基类导航栏
class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .mainBlue
        navigationBar.setBackgroundImage(UIImage(named: "banner"), for: .default)
    }
}
