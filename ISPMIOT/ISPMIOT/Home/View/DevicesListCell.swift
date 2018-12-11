import UIKit

class DevicesListCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        mainView.backgroundColor = .backgroundBlue1
        mainView.borderWidth = 1
        mainView.cornerRadius = 5
        mainView.borderColor = .blue
        mainView.clipsToBounds = true
    }
    
    func setup() {
        
    }
}
