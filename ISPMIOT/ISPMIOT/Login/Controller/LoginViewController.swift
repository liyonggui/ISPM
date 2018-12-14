import UIKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: BaseButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 测试数据
        usernameTF.text = "admin"
        passwordTF.text = "admin"
        
//        loginButton.isEnabled = false
        usernameTF.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc func valueChanged() {
        guard let name = usernameTF.text, let pass = passwordTF.text else {
            return
        }
        loginButton.isEnabled = !name.isEmpty && !pass.isEmpty
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        guard let username = usernameTF.text, let password = passwordTF.text, !username.isEmpty && !password.isEmpty else {
            showAlert(message: "账号或密码不可为空")
            return
        }
        
        showActivityHUD()
        interfaceSharedInstance.userService.login(username: username, password: password).successOrShowError(on: self) {
            interfaceSharedInstance.loggedUser = $0
            IOTNotificationCenter.defaultCenter.post(notificationType: .userLoggedIn)
        }        
    }
    
}
