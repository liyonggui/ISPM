import UIKit
import Charts

/// 图表VC
class ChartsViewController: BaseViewController {

    @IBOutlet weak var mainTableView: BaseTableView!
    
    // MARK: - 初始化方法
    override init() {
        super.init()
    }
    
    init(_ model: MonitorModelel) {
        super.init()
        setNavigationBar(title: model.typeStr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - 生命s周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - 设置UI
    private func setupUI() {
//        let pieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
//        pieChartView.backgroundColor = .white
//        view.addSubview(pieChartView)
        setupTableView()
    }
    
    private func setupTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.registerNib(ChartsCell.self)
    }
}

// MARK: - 数据源
extension ChartsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(of: ChartsCell.self, for: indexPath, defaultCell: nil, configure: { cell in
//            cell.se
            // 第一次默认选中第一行
//            if indexPath.row == 0, first {
//                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
//            }
//            cell.setup(projectList[indexPath.row])
        })
    }
}

// MARK: - 代码方法
extension ChartsViewController: UITableViewDelegate {
    
}
