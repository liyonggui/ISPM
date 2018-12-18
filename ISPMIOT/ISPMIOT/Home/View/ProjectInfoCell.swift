import UIKit

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let img = UIImageView(frame: imgScrollView.bounds)
        let img1 = UIImageView(frame: CGRect(x: imgScrollView.frame.width, y: 0, width: imgScrollView.frame.width
            , height: imgScrollView.frame.height))
        img.image = UIImage(named: "jianzhu")
        img1.image = UIImage(named: "jianzhu")
        imgScrollView.addSubview(img)
        imgScrollView.addSubview(img1)
        imgScrollView.contentSize = CGSize(width: imgScrollView.frame.width * 2, height: 0)
        imgScrollView.isPagingEnabled = true
    }
    
    func setup() {
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        let d = NSMutableAttributedString(string: "30", attributes: [NSAttributedString.Key.foregroundColor : UIColor.green])
        let s = NSMutableAttributedString(string: "20", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        let f = NSMutableAttributedString(string: "10", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        let a = NSMutableAttributedString(string: "/", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        attributedStrM.append(d)
        attributedStrM.append(a)
        attributedStrM.append(s)
        attributedStrM.append(a)
        attributedStrM.append(f)
        environmentLabel.attributedText = attributedStrM
        faceLabel.attributedText = attributedStrM
        cameraLabel.attributedText = attributedStrM
        craneLabel.attributedText = attributedStrM
    }
    
    private func setImgs() {
        
    }
    
}
