import UIKit
import IQKeyboardManagerSwift

/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.width
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.height
/// 屏幕bounds
let SCREEN_BOUNDS = UIScreen.main.bounds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var mainTabBarController: MainTabBarController = {
        let mainTabBarController = MainTabBarController()
        return mainTabBarController
    }()
    
    lazy var loginVC: LoginViewController = {
       return LoginViewController()
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IOTNotificationCenter.defaultCenter.addObserver(self, selector: #selector(logined), notificationType: .userLoggedIn)
        IQKeyboardManager.shared.enable = true
        setupWindow()
        interfaceSharedInstance = Interface(environment: .qa, applicationSource: "IOT")
        return true
    }
    
    @objc func logined() {
        window?.rootViewController = mainTabBarController
    }
    
    private func setupWindow() {
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = loginVC
            window?.makeKeyAndVisible()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}