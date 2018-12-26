import UIKit

/// 代理
protocol DevicesImgCellDelegate: class {
    func didTapImg(_ cell: DevicesImgCell)
}

extension DevicesImgCellDelegate {
    func didTapImg(_ cell: DevicesImgCell) {}
}

/// 设备分布图cell
class DevicesImgCell: BaseTableViewCell {
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    @IBOutlet weak var imgView: UIImageView!
    var delegate: DevicesImgCellDelegate?
    
    /// 设置cell
    func setup(_ url: String, delegate: DevicesImgCellDelegate) {
//        guard let model = model else {
//            return
//        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImg))
        self.delegate = delegate
        imgView.addGestureRecognizer(tap)
        imgView.isUserInteractionEnabled = true
        imgView.sd_setImage(with: URL(string: url), completed: nil)
    }
    
    /// 点击图片
    @objc func didTapImg() {
        delegate?.didTapImg(self)
        MyPrint("asdfewrsdfs")
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
