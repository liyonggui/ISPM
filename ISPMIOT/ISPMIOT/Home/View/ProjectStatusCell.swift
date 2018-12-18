import UIKit

class ProjectStatusCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var aveDayLabel: UILabel!
    @IBOutlet weak var aveMonthLabel: UILabel!
    @IBOutlet weak var lowestLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    
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
    
    func setup(_ model: MonitorModelel, type: CellTape?) {
        guard let type = type else {
            return
        }
        var data = ""
        var time = ""
        var aveDay = ""
        var aveMonth = ""
        var lowest = ""
        var record = ""
        var icon: UIImage?
        switch type {
        case .pm25:
            data = ""
            time = ""
            aveDay = ""
            aveMonth = ""
            lowest = ""
            record = ""
            icon = UIImage(named: "pmIcon")
        case .pm10:
            icon = UIImage(named: "pmIcon")
        case .humidity:
            icon = UIImage(named: "humidity")
        case .temperature:
            icon = UIImage(named: "temperature")
        default: break
        }
        iconImg.image = icon
        dataLabel.text = data
        timeLabel.text = time
        aveDayLabel.text = aveDay
        aveMonthLabel.text = aveMonth
        lowestLabel.text = lowest
        recordLabel.text = record
    }
    
    private func set() {
        
    }
}
