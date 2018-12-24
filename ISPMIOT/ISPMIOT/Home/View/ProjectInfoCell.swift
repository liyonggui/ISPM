import UIKit
import SDWebImage

/// 代理
protocol ProjectInfoCellDelegate: class {
    func didTapImg(_ cell: BaseTableViewCell)
}

extension ProjectInfoCellDelegate {
    func didTapImg(_ cell: BaseTableViewCell) {}
}

/// 项目信息cell
class ProjectInfoCell: BaseTableViewCell {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var offlineLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var environmentLabel: UILabel!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var craneLabel: UILabel!
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    var delegate: ProjectInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [totalLabel, onlineLabel, offlineLabel, errorLabel, environmentLabel, faceLabel, cameraLabel, craneLabel].forEach {
            $0?.adjustsFontSizeToFitWidth = true
            $0?.minimumScaleFactor = 0.5
        }
    }
    
    /// 点击图片
    @objc func didTapImg() {
        delegate?.didTapImg(self)
        MyPrint("asdfewrsdfs")
    }
    
    /// 设置cell
    func setup(_ model: ProjectModel?, delegate: ProjectInfoCellDelegate) {
        guard let model = model else {
            return
        }
        totalLabel.text = "总数：\(model.totalCount)"
        onlineLabel.text = "在线：\(model.availableCount)"
        offlineLabel.text = "离线：\(model.totalCount)"
        errorLabel.text = "错误：\(model.totalCount)"
        self.delegate = delegate
        // 测试数据
//        totalLabel.text = "总数：2"
//        onlineLabel.text = "在线：2"
//        offlineLabel.text = "离线：0"
//        errorLabel.text = "错误：0"
        
        model.devices.forEach {
            // 类别(1.人脸识别柱,2.视频监控,3.环境监测仪,4.塔吊,5.其它)
//            let model = $0
//            model.availableCount = 0
//            model.outlineCount = 0
//            model.unavailableCount = 0
            let model = $0
            switch model.category {
            case "1":
//                model.availableCount = 1
                faceLabel.attributedText = getAttributedString(model)
            case "2":
                cameraLabel.attributedText = getAttributedString(model)
            case "3":
//                model.availableCount = 1
                environmentLabel.attributedText = getAttributedString(model)
            case "4":
                craneLabel.attributedText = getAttributedString(model)
            default: break
            
            }
        }
        setImgs(model.images)
    }
    
    /// 设置各项数据
    private func getAttributedString(_ model: DevicesTotalModel) -> NSMutableAttributedString {
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        let one = NSMutableAttributedString(string: "\(model.availableCount)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.green])
        let two = NSMutableAttributedString(string: "\(model.outlineCount)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        let three = NSMutableAttributedString(string: "\(model.unavailableCount)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        let diagonal = NSMutableAttributedString(string: "/", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        attributedStrM.append(one)
        attributedStrM.append(diagonal)
        attributedStrM.append(two)
        attributedStrM.append(diagonal)
        attributedStrM.append(three)
        return attributedStrM
    }
    
    /// 设置图片
    private func setImgs(_ imgURLArr: [String]) {
        // 移除所有控件
        imgScrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        var index = 0
        imgURLArr.forEach {
            let img = UIImageView(frame: CGRect(x: imgScrollView.width * CGFloat(index), y: 0, width: imgScrollView.width, height: imgScrollView.height))
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImg))
            img.addGestureRecognizer(tap)
            img.isUserInteractionEnabled = true
            imgScrollView.addSubview(img)
            img.sd_setImage(with: URL(string: $0), completed: nil)
            index += 1
        }
        
        imgScrollView.contentSize = CGSize(width: imgScrollView.width * CGFloat(imgURLArr.count), height: 0)
        imgScrollView.isPagingEnabled = true
    }
    
}
