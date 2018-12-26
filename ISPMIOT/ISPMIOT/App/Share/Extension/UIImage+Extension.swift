import UIKit

protocol ImageSettable {
    associatedtype Name: RawRepresentable
}

extension UIImage: ImageSettable {
    enum Name: String {
        case homeIcon = "homeIcon"
    }
    
    convenience init?(named name: Name) {
        self.init(named: name.rawValue)
    }
}

// MARK: - 图片缩小
extension UIImage {
    
    /// 重设图片大小
    func reSizeImage(reSize: CGSize)-> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    /// 等比率缩放
    func scaleImage(scaleSize: CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
