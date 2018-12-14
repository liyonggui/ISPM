import UIKit

class ProjectStatusCell: BaseTableViewCell {
        
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pm25Label: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var noiseLevelLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var windPowerLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
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
    
    func setup(_ model: MonitorModelel) {
        pm25Label.text = "\(model.pm25)"
        humidityLabel.text = "\(model.humidity)"
        noiseLevelLabel.text = "\(model.noiseLevel)"
        pressureLabel.text = "\(model.pressure)"
        temperatureLabel.text = "\(model.temperature)"
        windDirectionLabel.text = model.windDirection
        windPowerLabel.text = "\(model.windPower)"
        windSpeedLabel.text = "\(model.windSpeed)"
    }
}
