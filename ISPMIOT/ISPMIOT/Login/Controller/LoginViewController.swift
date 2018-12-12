import UIKit

class LoginViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        IOTNotificationCenter.defaultCenter.post(notificationType: .userLoggedIn)
    }
    
}
