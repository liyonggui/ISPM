import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var listItemView: UIView!
    @IBOutlet weak var contantTableView: UIView!
    @IBOutlet weak var projectInfoView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: BaseTableView!
    @IBOutlet weak var tapSegmented: UISegmentedControl!
    
    @IBOutlet weak var projectNameLabel: LabelWhite16!
    @IBOutlet weak var typeLabel: LabelWhite14!
    @IBOutlet weak var areaLabel: LabelWhite14!
    @IBOutlet weak var timeLabel: LabelWhite14!
    @IBOutlet weak var addressLabel: LabeBluel12!
    @IBOutlet weak var iconImageView: UIImageView!
    
    lazy var listItemViewController: ListItemViewController = {
        let vc = ListItemViewController()
        return vc
    }()
    
    var selectedState: State = .project {
        didSet {
            mainTableView.reloadData()
        }
    }
    
    var monitorArray: [MonitorModelel] = []
    var devicesArray: [DevicesModel] = []
    var projectModel: ProjectModel? {
        didSet {
            if let model = projectModel {
                loadEnvMonitor(model)
                loadDevices(model)
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar(title: NavTitle.projectInformation)
        setupUI()
        loadProjectList()
        setupCallBack()
    }
    
    /// 设置点击回调的闭包
    private func setupCallBack() {
        listItemViewController.callBack = { model in
            self.projectModel = model
        }
    }
    
    /// 网络请求项目列表
    private func loadProjectList() {
        interfaceSharedInstance.projectService.getProjects().successOrShowError(on: self) {
            self.listItemViewController.projectList = $0
            self.projectModel = $0.first
        }
    }
    
    /// 网络请求设备列表
    private func loadDevices(_ model: ProjectModel) {
        interfaceSharedInstance.projectService.getDevices(model).successOrShowError(on: self) {
            self.devicesArray = $0
        }
    }
    
    /// 网络请求环境数据
    ///
    /// - Parameter model: 项目模型
    private func loadEnvMonitor(_ model: ProjectModel) {
        interfaceSharedInstance.projectService.getEnvMonitor(model).successOrShowError(on: self) {
            guard $0.count > 0 else { return }
            self.monitorArray = $0
            self.mainTableView.reloadData()
        }
    }
    
    
    // MARK: - UI 设置
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
        switch selectedState {
        case .project:
            return monitorArray.count
        case .devices:
            return devicesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedState {
        case .project:
            return tableView.dequeueReusableCell(of: ProjectStatusCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                cell.setup(self.monitorArray[indexPath.row])
            })
        case .devices:
            return tableView.dequeueReusableCell(of: DevicesListCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                cell.setup(self.devicesArray[indexPath.row])
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
