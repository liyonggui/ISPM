import UIKit

class ListItemViewController: BaseViewController {
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(of: ListItemTableViewCell.self, for: indexPath, defaultCell: nil, configure: { cell in
            cell.setup()
            print(cell)
        })
    }
}

// MARK: - UITableViewDelegate
extension ListItemViewController: UITableViewDelegate {

}
