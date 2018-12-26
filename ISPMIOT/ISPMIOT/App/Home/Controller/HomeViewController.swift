import UIKit
import MapKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var listItemView: UIView!
    @IBOutlet weak var contantTableView: UIView!
    @IBOutlet weak var projectInfoView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: BaseTableView!
    @IBOutlet weak var tapSegmented: UISegmentedControl!
    @IBOutlet weak var headerView: BaseMainView!
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var contactLbel: UILabel!
    
    lazy var listItemViewController: ListItemViewController = {
        let vc = ListItemViewController()
        return vc
    }()
    
    var selectedState: State = .project
    
    /// 环境模型数组
    var monitorArray: [MonitorModelel] = []
    /// 设备模型数组
    var devicesArray: [DevicesModel] = []
    /// 项目模型数组
    var projectArray: [ProjectModel] = []
    /// 当前选中项目模型
    var projectModel: ProjectModel? {
        didSet {
            setupProjectInfo(projectModel)
        }
    }
    
    /// 地图编码器
    lazy var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    // 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
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
    
    /// 设置项目信息展示
    private func setupProjectInfo(_ model: ProjectModel?) {
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
    
    /// 网络请求环境数据
    private func loadEnvMonitor(_ model: ProjectModel) {
        showActivityHUD()
        interfaceSharedInstance.projectService.getEnvMonitor(model).onSuccess {
            self.monitorArray = $0
            self.loadDevices(model)
        }
    }
    
    /// 网络请求设备列表
    private func loadDevices(_ model: ProjectModel) {
        interfaceSharedInstance.projectService.getDevices(model).successOrShowError(on: self) {
            self.devicesArray = $0
            self.mainTableView.reloadData()
        }
    }
    
    // 设置nav
    private func setupNav() {
        setNavigationBar(title: NavTitle.projectInformation)
        setNavigationBarHidden()
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
    
    // 设置tableview
    private func setupTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.registerNib(ProjectStatusCell.self)
        mainTableView.registerNib(DevicesListCell.self)
        mainTableView.registerNib(ProjectInfoCell.self)
        mainTableView.registerNib(DevicesImgCell.self)
        
        mainTableView.backgroundColor = .clear
//        mainTableView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    // MARK: - 点击事件
    /// 点击地图
    @IBAction func didTapMap(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let appleAction = UIAlertAction(title: "苹果地图", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            guard let address = self.projectModel?.address else { return }
            
            self.geoCoder.geocodeAddressString(address) { (pls: [CLPlacemark]?, error: Error?)  in
                if error == nil {
                    guard let plsResult = pls, let firstPL = plsResult.first, let loc = firstPL.location?.coordinate else { return }
                    let currentLocation = MKMapItem.forCurrentLocation()
                    let toLocation = MKMapItem(placemark:MKPlacemark(coordinate:loc,addressDictionary:nil))
                    toLocation.name = address
                    MKMapItem.openMaps(with: [currentLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: NSNumber(value: true)])
                    if let url = URL(string: address) {
                        UIApplication.shared.canOpenURL(url)
                    }
                } else {
                    MyPrint("error: 编码错误")
                    MyPrint(error)
                }
            }
        })
        
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        optionMenu.addAction(cancel)
        optionMenu.addAction(appleAction)
        present(optionMenu, animated: true, completion: nil)
    }
    
    /// 点击切换
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
        mainTableView.reloadData()
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
        case .devicesImg:
            return self.projectModel?.images.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedState {
        case .project: // 实时监控
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
        case .devicesImg: // 设备分布图
            return tableView.dequeueReusableCell(of: DevicesImgCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                if let images = self.projectModel?.images {
                    cell.setup(images[indexPath.row], delegate: self)
                }
            })
        case .devices: // 设备列表
            return tableView.dequeueReusableCell(of: DevicesListCell.self, for: indexPath, defaultCell: nil, configure: { cell in
                cell.setup(self.devicesArray[indexPath.row])
            })
        }
        
    }
    
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedState {
        case .project:
            guard indexPath.row > 0, let type = EnvironmentParameterType(rawValue: indexPath.row - 1) else { return }
            let vc = ChartsViewController(self.monitorArray[type.rawValue])
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}

// MARK: - DevicesImgCellDelegate
extension HomeViewController: DevicesImgCellDelegate {
    func didTapImg(_ cell: DevicesImgCell) {
        MyPrint("sdfsdf")
//        guard let index = mainTableView.indexPath(for: cell), let model = projectModel else {
//            return
//        }

    }
}

// MARK: - enum

/// 返回cell的类型
///
/// - project: 项目状态
/// - devicesImg: 设备分布
/// - devices: 设备列表
enum State: Int {
    case project = 0
    case devicesImg
    case devices
}
