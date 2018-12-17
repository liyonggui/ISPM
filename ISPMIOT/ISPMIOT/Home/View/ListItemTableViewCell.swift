import UIKit

class ListItemTableViewCell : BaseTableViewCell, NibLoadable {
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var cellBgView: CellBackgroundView = {
        return CellBackgroundView.loadFromNib()
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .default
        selectedBackgroundView = cellBgView
        addShadow(cgColor: UIColor.white.cgColor)
    }
    
    func setup(_ model: ProjectModel) {
        titleLabel.text = model.name
    }
}
