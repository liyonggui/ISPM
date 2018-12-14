import UIKit

class ListItemTableViewCell : BaseTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow(cgColor: UIColor.white.cgColor)
    }
    
    func setup(_ model: ProjectModel) {
        titleLabel.text = model.name
    }
}
