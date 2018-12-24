import UIKit

/// VC 基类
class BaseViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainBlue
    }
    
}

// MARK: - 显示HUB
extension BaseViewController {
    func showActivityHUD() {
        view.showActivityHUD()
    }
    
    func hideActivityHUD() {
        view.hideActivityHUD()
    }
}

// MARK: - 显示Alert
extension BaseViewController {
    func showAlert(_ title: String? = "提示", message: String, actionTitle: String? = nil, from viewController: UIViewController? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle ?? "确定", style: .cancel, handler: handler))
        alert.showAnimated(true, from: viewController)
    }
    
    func showError(_ error: NSError?) {
        guard let errorMsg = error?.domain else {
            return
        }
        showAlert("提示", message: errorMsg.isEmpty ? "网络连接失败" : errorMsg)
    }
}

// MARK: - 设置nav
extension BaseViewController {
    func setNavigationBar(title: String, withSubTitle subtitle: String? = .none, color: UIColor? = nil, font: UIFont? = nil, sizeToFit: Bool = true) {
        if let subtitle = subtitle {
            self.navigationItem.titleView = DoubleTitleView(title: title, subtitle: subtitle, sizeToFit: sizeToFit)
        } else {
            self.navigationItem.titleView = SingleTitleView(title: title, color: color, font: font, sizeToFit: sizeToFit)
        }
    }
    
    func setNavigationBar(attributedTitle attributedString: NSAttributedString, sizeToFit: Bool = true) {
        let titleView = SingleTitleView(title: attributedString.string, sizeToFit: sizeToFit)
        titleView.mainTitle.attributedText = attributedString
        self.navigationItem.titleView = titleView
    }
    
    func setNavigationBar(attributedTitle attributedString: NSAttributedString, attributedSubTitle: NSAttributedString, sizeToFit: Bool = true, showDropDownArrow: Bool = false) {
        let titleView = DoubleTitleView(title: attributedString.string, subtitle: attributedSubTitle.string, sizeToFit: sizeToFit, showDropDownArrow: showDropDownArrow)
        titleView.mainTitle.attributedText = attributedString
        titleView.subtitle.attributedText = attributedSubTitle
        
        self.navigationItem.titleView = titleView
    }
    
    func setNavigationBar(image: UIImage) {
        let logo = UIImageView(image: image)
        navigationItem.titleView = logo
    }
    
    // For Tests
    var navigationBarTitleText: String? {
        guard let titleView = navigationItem.titleView else {
            return navigationItem.title
        }
        
        switch titleView {
        case is SingleTitleView: return (titleView as? SingleTitleView)?.mainTitle.text
        case is DoubleTitleView: return (titleView as? DoubleTitleView)?.mainTitle.text
        default: return nil
        }
    }
    
    var navigationBarSubTitleText: String? {
        guard let titleView = navigationItem.titleView as? DoubleTitleView else { return nil }
        return titleView.subtitle.text
    }
}

/// SingleTitleView - 一行文本
private class SingleTitleView: UIView {
    lazy var mainTitle: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 1, width: self.bounds.width, height: self.bounds.height))
        label.font = UIFont.TisaSans.light.sized(.xlarge)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    init(title: String, color: UIColor? = nil, font: UIFont? = nil, sizeToFit: Bool = true) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 140, height: 44))
        addSubview(self.mainTitle)
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        mainTitle.constrainToParent([.top, .bottom, .left, .right])
        if let color = color { mainTitle.textColor = color }
        if let font = font { mainTitle.font = font }
        self.mainTitle.text = title
        if sizeToFit { self.mainTitle.sizeToFit() }
        self.frame = CGRect(x: 0, y: 1, width: self.bounds.width, height: self.bounds.height)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// DoubleTitleView - 两行文本
private class DoubleTitleView: UIView {
    lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.TisaSans.regular.sized(.regular)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var dropDownArrow: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "▾"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.TisaSans.regular.sized(.xsmall)
        label.textAlignment = .center
        label.textColor = .gray4
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    init(title: String, subtitle: String, sizeToFit: Bool = true, showDropDownArrow: Bool = false) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 140, height: 44))
        self.mainTitle.text = title
        self.subtitle.text = subtitle
        
        let titleStackView = UIStackView(arrangedSubviews: [self.mainTitle, self.subtitle])
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.spacing = -5
        titleStackView.alignment = .center
        
        addSubview(titleStackView)
        
        titleStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        titleStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        titleStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        guard showDropDownArrow else { return }
        mainTitle.addSubview(dropDownArrow)
        dropDownArrow.centerYAnchor.constraint(equalTo: mainTitle.centerYAnchor, constant: -2.0).isActive = true
        dropDownArrow.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
        dropDownArrow.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
        dropDownArrow.rightAnchor.constraint(equalTo: mainTitle.rightAnchor, constant: 15.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superview = superview else { return }
        let centerX = superview.convert(center, to: self).x
        mainTitle.center = CGPoint(x: centerX, y: mainTitle.center.y)
        subtitle.center = CGPoint(x: centerX, y: subtitle.center.y)
    }
}
