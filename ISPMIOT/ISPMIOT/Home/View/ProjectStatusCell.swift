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
        
        [dataLabel, timeLabel, aveDayLabel, aveMonthLabel, lowestLabel, recordLabel].forEach {
            $0?.adjustsFontSizeToFitWidth = true
            $0?.minimumScaleFactor = 0.5
        }
    }
    
    /// 设置数据
    ///
    /// - Parameter model: 传入模型
    func setup(_ model: MonitorModelel) {
        dataLabel.text = "\(model.latestData)"
        timeLabel.text = model.createTime
        aveDayLabel.text = "\(model.todayAvg)"
        aveMonthLabel.text = "\(model.monthAvg)"
        lowestLabel.text = "\(model.min)"
        recordLabel.text = "\(model.max)"
        
        var icon: UIImage?
        switch model.envType {
        case .pm25:
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
    }
    
    private func set() {
        
    }
}
