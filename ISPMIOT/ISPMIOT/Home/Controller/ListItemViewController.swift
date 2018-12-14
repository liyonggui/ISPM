import UIKit

class ListItemViewController: BaseViewController {
    
    var projectList: [ProjectModel] = [] {
        didSet  {
            self.tableView.reloadData()
        }
    }
    var callBack: ((ProjectModel) -> Void)?
    
    lazy var tableView: BaseTableView = {
        let tableVeiw = BaseTableView()
        tableVeiw.delegate = self
        tableVeiw.dataSource = self
        tableVeiw.registerNib(ListItemTableViewCell.self)
        return tableVeiw
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
}

// MARK: - UITableViewDataSource
extension ListItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(of: ListItemTableViewCell.self, for: indexPath, defaultCell: nil, configure: { cell in
            cell.setup(projectList[indexPath.row])
        })
    }
}

// MARK: - UITableViewDelegate
extension ListItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callBack?(projectList[indexPath.row])
    }
}
