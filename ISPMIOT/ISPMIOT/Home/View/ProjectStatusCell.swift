import UIKit

/// 环境监测cell
class ProjectStatusCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var aveDayLabel: UILabel!
    @IBOutlet weak var aveMonthLabel: UILabel!
    @IBOutlet weak var lowestLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        mainView.backgroundColor = .backgroundBlue1
        mainView.borderWidth = 1
        mainView.cornerRadius = 10
        mainView.borderColor = .borderColorBlue
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
        if let type = model.envType {
            var title: String?
            switch type {
            case .pm25: title = "PM2.5"
            case .pm10: title = "PM10"
            case .humidity: title = "温度"
            case .temperature: title = "湿度"
            case .pressure: title = "压力"
            case .noiseLevel: title = "噪声"
            case .windPower: title = "风力"
            case .tsp: title = "TSP"
            case .windSpeed: title = "风速"
            }
            titleLabel.text = title
        }
    }
    
    private func set() {
        
    }
}
