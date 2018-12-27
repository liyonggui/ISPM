import UIKit

class CameraCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.backgroundColor = UIColor.randomColor
    }
}
