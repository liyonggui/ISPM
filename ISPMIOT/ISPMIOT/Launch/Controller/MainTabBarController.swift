import UIKit

class MainTabBarController: UITabBarController {
    
    private(set) var _homeViewController: BaseNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupChildViewControllers()
        setUpTabBarAssets()
        setupUI()
    }
        
    private func setupChildViewControllers() {
        setViewControllers([homeViewController], animated: false)
    }
        
    // MARK: - setup UI
    private func setupUI() {
        tabBar.barTintColor = .mainBlue
//        tabBar.backgroundImage = UIImage(named: "banner")
        let item = UITabBarItem.appearance()
        item.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .normal)
        item.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
    }
    
    private func setUpTabBarAssets() {
        guard let homeIcon = UIImage(named: .homeIcon) else {
                return
        }

        let homeTitle = TabTitle.home
        
        let icons = [homeIcon]
        let titles =  [homeTitle]

        for i in 0..<icons.count {
            tabBar.items?[i].image = icons[i]
            tabBar.items?[i].title = titles[i]
        }
    }
    
    // MARK: - homeViewController
    var homeViewController: BaseNavigationController {
        get {
            if let homeVC = _homeViewController {
                return homeVC
            } else {
                let homeVC = HomeViewController()
                let nav = BaseNavigationController(rootViewController: homeVC)
                _homeViewController = nav
                return nav
            }
        }
        set {
            _homeViewController = newValue
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    
}
