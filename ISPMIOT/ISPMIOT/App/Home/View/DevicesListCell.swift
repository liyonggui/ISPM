import UIKit

/// 设备列表cell
class DevicesListCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: LabelWhite17!
    @IBOutlet weak var countLabel: LabelWhite12!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        mainView.backgroundColor = .backgroundBlue1
        mainView.borderWidth = 1
        mainView.cornerRadius = 5
        mainView.borderColor = .borderColorBlue
        mainView.clipsToBounds = true
    }
    
    func setup(_ model: DevicesModel) {
        titleLabel.text = model.name
        countLabel.text = "\(model.count)"
    }
}
