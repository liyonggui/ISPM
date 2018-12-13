import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var listItemView: UIView!
    @IBOutlet weak var contantTableView: UIView!
    @IBOutlet weak var projectInfoView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: BaseTableView!
    @IBOutlet weak var tapSegmented: UISegmentedControl!
    
    lazy var listItemViewController: ListItemViewController = {
        let vc = ListItemViewController()
        return vc
    }()
    
    var selectedState: State = .project {
        didSet {
            mainTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar(title: NavTitle.projectInformation)
        setupUI()
//        self.navigationController?.addChild(listItemViewController)
        
    }
    
    private func setupUI() {
        leadingConstraint.constant = 0
        
        if let listView = listItemViewController.view {
            let frame = CGRect(x: 0, y: 0, width: contantTableView.frame.width, height: contantTableView.frame.height)
            listView.frame = frame
            contantTableView.addSubview(listView)
        }
        
        setupTableView()
    }
    
    private func setupTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.registerNib(ProjectStatusCell.self)
        mainTableView.registerNib(DevicesListCell.self)
        mainTableView.backgroundColor = .clear
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
    
    @IBAction func didTapTabSegmented(_ sender: UISegmentedControl) {
        selectedState = State(rawValue: sender.selectedSegmentIndex) ?? .project
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedState {
        case .project:
            return tableView.dequeueReusableCell(of: ProjectStatusCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                cell.setup()
            })
        case .devices:
            return tableView.dequeueReusableCell(of: DevicesListCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                cell.setup()
            })
        }
        
    }
    
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
}

// MARK: - enum
enum State: Int {
    case project = 0
    case devices
}
