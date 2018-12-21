import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var listItemView: UIView!
    @IBOutlet weak var contantTableView: UIView!
    @IBOutlet weak var projectInfoView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: BaseTableView!
    @IBOutlet weak var tapSegmented: UISegmentedControl!
    @IBOutlet weak var headerView: BaseMainView!
    
    @IBOutlet weak var projectNameLabel: LabelWhite16!
    @IBOutlet weak var typeLabel: LabelWhite14!
    @IBOutlet weak var timeLabel: LabelWhite14!
    @IBOutlet weak var addressLabel: LabeBluel12!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ownerLabel: LabelWhite14!
    @IBOutlet weak var contactLbel: LabelWhite14!
    
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
    var projectArray: [ProjectModel] = []
    var projectModel: ProjectModel? {
        didSet {
            setup(projectModel)
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
    
    private func setup(_ model: ProjectModel?) {
        guard let model = projectModel else {
            return
        }
        
        projectNameLabel.text = model.name
        ownerLabel.text = "业主：" + model.ownerName
        typeLabel.text = "类型：" + model.typeStr
        addressLabel.text = "地址：" + model.address
        timeLabel.text = "开工时间：" + model.startDate
        contactLbel.text = "联系方式：" + model.ownerPhone + "(\(model.ownerName))"
        loadEnvMonitor(model)
        if let _ = mainTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProjectInfoCell {
            mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    /// 网络请求项目列表
    private func loadProjectList() {
        interfaceSharedInstance.projectService.getProjects().successOrShowError(on: self) {
            self.listItemViewController.projectList = $0
            // 第一次默认显示第一个
            self.projectModel = $0.first
        }
    }
    
    /// 网络请求项目列表和环境数据
    ///
    /// - Parameter model: 项目模型
    private func loadEnvMonitor(_ model: ProjectModel) {
        showActivityHUD()
        interfaceSharedInstance.projectService.getEnvMonitor(model).onSuccess {
            guard $0.count > 0 else { return }
            self.monitorArray = $0
            interfaceSharedInstance.projectService.getDevices(model).successOrShowError(on: self) {
                self.devicesArray = $0
                self.mainTableView.reloadData()
            }
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
        // 设置字体最小值
        [projectNameLabel, addressLabel, timeLabel, ownerLabel, contactLbel, addressLabel].forEach {
            $0?.adjustsFontSizeToFitWidth = true
            $0?.minimumScaleFactor = 0.5
        }
        tapSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        setupTableView()
    }
    
    private func setupTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.registerNib(ProjectStatusCell.self)
        mainTableView.registerNib(DevicesListCell.self)
        mainTableView.registerNib(ProjectInfoCell.self)
        mainTableView.backgroundColor = .clear
        mainTableView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
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
            return monitorArray.count + 1
        case .devices:
            return devicesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedState {
        case .project:
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(of: ProjectInfoCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                    cell.setup(self.projectModel)
                })
            } else {
                return tableView.dequeueReusableCell(of: ProjectStatusCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                    if let type = EnvironmentParameterType(rawValue: indexPath.row - 1) {
                        cell.setup(self.monitorArray[type.rawValue])
                    }
                })
            }
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

/// 返回cell的类型
///
/// - project: 项目状态
/// - devices: 设备列表
enum State: Int {
    case project = 0
    case devices
}

/// cell 类型
///
/// - pm25: PM2.5
/// - pm10: PM10
/// - temperature: 温度
/// - humidity: 湿度
/// - pressure: 气压
/// - windSpeed: 风速
/// - noiseLevel: 噪音
/// - windPower: 风力
/// - tsp: 总悬浮微粒
//enum CellTape: Int {
//    case pm25 = 0
//    case pm10
//    case temperature
//    case humidity
//    case pressure
//    case windSpeed
//    case noiseLevel
//    case windPower
//    case tsp
//}
