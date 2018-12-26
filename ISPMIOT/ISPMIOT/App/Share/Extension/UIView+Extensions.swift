import UIKit
import MBProgressHUD

// MARK: layout
extension UIView {
    
    enum PlannerLayoutEdge {
        case top
        case left
        case right
        case bottom
        case centerX
        case centerY
    }
    
    func constrainToParent(_ edges: Set<PlannerLayoutEdge>, constant: CGFloat = 0) {
        guard let parentView = superview else { return }
        edges.forEach {
            switch $0 {
            case .top:
                topAnchor.constraint(equalTo: parentView.topAnchor, constant: constant).isActive = true
            case .left:
                leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: constant).isActive = true
            case .right:
                trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -constant).isActive = true
            case .bottom:
                bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -constant).isActive = true
            case .centerX:
                centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: constant).isActive = true
            case .centerY:
                centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: constant).isActive = true
            }
        }
    }
    
    func centerOnParent() {
        guard let parentView = superview else { return }
        centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: 0).isActive = true
        centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: 0).isActive = true
    }
    
    @nonobjc static var reuseId: String { return String(describing: self) }

}

// MARK: Shadows
extension UIView {
    func addShadow(cgColor: CGColor = UIColor.black.cgColor, height: CGFloat = 2.0, radius: CGFloat = 4.0, opacity: Float = 0.12) {
        layer.shadowColor = cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
    func addGradientShadow(width: CGFloat, height: CGFloat = 5.0, backgroundColor: UIColor = .gray9, stopColor: CGColor = UIColor.gray7.cgColor, startColor: CGColor = UIColor.gray9.cgColor) {
        self.backgroundColor = backgroundColor
        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize(width: width, height: height)
        let stopColor = stopColor
        let startColor = startColor
        gradient.colors = [stopColor, startColor]
        gradient.locations = [0.0, 0.8]
        layer.addSublayer(gradient)
    }
}

// MARK: IBInspectable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            layer.borderColor = newValue.cgColor
        }
    }
}

extension UIView {
    
    /// 显示HUB
    func showActivityHUD() {
        DispatchQueue.main.async { () -> Void in
            MBProgressHUD.hide(for: self, animated: true)
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.label.text = "施工中..."
            hud.button.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    /// 隐藏HUB
    func hideActivityHUD() {
        DispatchQueue.main.async { () -> Void in
            MBProgressHUD.hide(for: self, animated: true)
        }
    }
}

/// 快速获取frame的各值
extension UIView{
    /// 获取视图的X坐标
    public var x:CGFloat{
        get{
            return self.frame.origin.x;
        }
        
        set{
            var frames = self.frame;
            frames.origin.x = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    /// 获取视图的Y坐标
    public var y:CGFloat{
        get{
            return self.frame.origin.y;
        }
        
        set{
            var frames = self.frame;
            frames.origin.y = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    /// 获取视图的宽
    public var width:CGFloat{
        get{
            return self.frame.size.width;
        }
        
        set{
            var frames = self.frame;
            frames.size.width = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    /// 获取视图的高
    public var height:CGFloat{
        get{
            return self.frame.size.height;
        }
        
        set{
            var frames = self.frame;
            frames.size.height = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    /// 获取最大的X坐标
    public var maxX:CGFloat{
        get{
            return self.x + self.width;
        }
        
        set{
            var frames = self.frame;
            frames.origin.x = CGFloat(newValue - self.width);
            self.frame = frames;
        }
    }
    
    /// 获取最大的Y坐标
    public var maxY:CGFloat{
        get{
            return self.y + self.height;
        }
        
        set{
            var frames = self.frame;
            frames.origin.y = CGFloat(newValue - self.height);
            self.frame = frames;
        }
    }
    
    /// 中心点X坐标
    public var centerX:CGFloat{
        get{
            return self.center.x;
        }
        set{
            self.center = CGPoint(x:CGFloat(newValue),y:self.center.y);
        }
    }
    
    /// 中心点Y坐标
    public var centerY:CGFloat{
        get{
            return self.center.y;
        }
        set{
            self.center = CGPoint(x:self.center.x,y:CGFloat(newValue));
        }
    }
    
    
    /// 删除所有的子视图
    func removeAllSubView() -> Void {
        for view : UIView in self.subviews{
            view.removeFromSuperview();
        }
    }
    
    /// 加载XIB文件
    public class func initWithXibName(xib:String) -> Any? {
        guard let nibs:Array = Bundle.main.loadNibNamed(xib, owner: nil, options: nil)else{
            return nil;
        }
        return nibs[0] ;
    }
    
    /// 设置边框
    func setBoardWithColor(color:UIColor,top:Bool,right:Bool,bottom:Bool,left:Bool,width:CGFloat) -> Void {
        if top == true {
            let layer:CALayer = CALayer();
            layer.frame = CGRect(x: 0, y: 0, width: self.width, height: width);
            layer.backgroundColor = color.cgColor;
            self.layer.addSublayer(layer);
        }
        if right == true {
            let layer:CALayer = CALayer();
            layer.frame = CGRect(x: self.width - width, y: 0, width: width, height: self.height);
            layer.backgroundColor = color.cgColor;
            self.layer.addSublayer(layer);
        }
        if bottom == true {
            let layer:CALayer = CALayer();
            layer.frame = CGRect(x: 0, y: self.height - width, width: self.width, height: width);
            layer.backgroundColor = color.cgColor;
            self.layer.addSublayer(layer);
        }
        if left == true {
            let layer:CALayer = CALayer();
            layer.frame = CGRect(x: 0, y: 0, width: width, height: self.height);
            layer.backgroundColor = color.cgColor;
            self.layer.addSublayer(layer);
        }
    }
}
