import UIKit

class DevicesListCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: LabelWhite17!
    
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
    
    func setup(_ model: DevicesModel) {
        titleLabel.text = model.name
    }
}
