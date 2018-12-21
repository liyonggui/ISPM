import UIKit

/// 基类导航栏
class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .mainBlue
    }
}
