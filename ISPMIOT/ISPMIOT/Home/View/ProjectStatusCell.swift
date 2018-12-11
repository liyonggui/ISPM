import UIKit

class ProjectStatusCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        mainView.backgroundColor = .backgroundBlue1
        mainView.borderWidth = 1
        mainView.cornerRadius = 10
        mainView.borderColor = .blue
        mainView.clipsToBounds = true
    }
    
    func setup() {
        
    }
}
