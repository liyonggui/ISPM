import UIKit

class BaseTableView: UITableView {
    
    init() {
        super.init(frame: CGRect.zero, style: .plain)
        setup()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        separatorStyle = .none
        backgroundColor = .secondaryBlue
    }
}
