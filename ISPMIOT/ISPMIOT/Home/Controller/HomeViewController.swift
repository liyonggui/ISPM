import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var listItemView: UIView!
    @IBOutlet weak var contantTableView: UIView!
    @IBOutlet weak var projectInfoView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    lazy var listItemViewController: ListItemViewController = {
        let vc = ListItemViewController()
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar(title: NavTitle.projectInformation)
        setupUI()
        
//        self.navigationController?.addChild(listItemViewController)
        if let listView = listItemViewController.view {
            let frame = CGRect(x: 0, y: 0, width: contantTableView.frame.width, height: contantTableView.frame.height)
            listView.frame = frame
            contantTableView.addSubview(listView)
        }
    }
    
    @IBAction func didTapArrow(_ sender: UIButton) {
        var leading: CGFloat = 0.0
        if leadingConstraint.constant == 0.0 {
            leading = view.bounds.width * 0.5
        } else {
            leading = 0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.leadingConstraint.constant = leading
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
        
    }
    
    private func setupUI() {
        leadingConstraint.constant = 0
    }
    
}
