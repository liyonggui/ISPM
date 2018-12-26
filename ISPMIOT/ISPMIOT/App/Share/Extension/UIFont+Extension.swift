import UIKit

// MARK: - Helper func
public protocol FontConvertible {
    func sized(_ size: UIFont.PatternFontSize) -> UIFont
}

// MARK: - Font Size Classes enum
public extension UIFont {
    public enum PatternFontSize: CGFloat {
        case title      = 32.0
        case xxlarge    = 22.0
        case xlarge     = 20.0
        case large      = 18.0
        case regular    = 16.0
        case small      = 14.0
        case xsmall     = 12.5
    }
}

// MARK: - Tisa enum 
public extension UIFont {
    public enum Tisa: FontConvertible {
        case light
        case regular
        case italic
        case bold
        case medium
        
        public func sized(_ size: UIFont.PatternFontSize) -> UIFont {
//            FontLoader.loadIfNeeded()
            var fontName: String
            
            switch self {
            case .light:    fontName = "TisaPro-Light"
            case .regular:  fontName = "TisaPro"
            case .medium:   fontName = "TisaPro-Medi"
            case .italic:   fontName = "TisaPro-Ita"
            case .bold:     fontName = "TisaPro-Bold"
            }
            
            let liningFigureAttributes: [UIFontDescriptor.FeatureKey: Any] = [
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberCaseType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseNumbersSelector
            ]
            
            let fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
                UIFontDescriptor.AttributeName.name: fontName,
                UIFontDescriptor.AttributeName.featureSettings: [liningFigureAttributes]
            ]
            
            let descriptor = UIFontDescriptor(fontAttributes: fontAttributes)
            let liningFigureFont = UIFont(descriptor: descriptor, size: size.rawValue)
            
            return liningFigureFont
        }
    }
}

// MARK: - TisaSans enum
public extension UIFont {
    public enum TisaSans: FontConvertible {
        case light
        case thin
        case regular
        case medium
        case bold
        
        public func sized(_ size: UIFont.PatternFontSize) -> UIFont {
//            FontLoader.loadIfNeeded()
            var fontName: String
            
            switch self {
            case .light:    fontName = "TisaSansPro-Light"
            case .thin:     fontName = "TisaSansPro-Thin"
            case .regular:  fontName = "TisaSansPro"
            case .medium:   fontName = "TisaSansPro-Medium"
            case .bold:     fontName = "TisaSansPro-Bold"
            }
            
            let liningFigureAttributes: [UIFontDescriptor.FeatureKey: Any] = [
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberCaseType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseNumbersSelector
            ]
            
            let fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
                UIFontDescriptor.AttributeName.name: fontName,
                UIFontDescriptor.AttributeName.featureSettings: [liningFigureAttributes]
            ]
            
            let descriptor = UIFontDescriptor(fontAttributes: fontAttributes)
            let liningFigureFont = UIFont(descriptor: descriptor, size: size.rawValue)
            
            return liningFigureFont
        }
    }
}

// MARK: Private
private class FontLoader {
    static let fonts: [(String, String)] = [
        ("TisaPro-Light", "otf"),
        ("TisaPro", "otf"),
        ("TisaPro-Medi", "otf"),
        ("TisaPro-Ita", "otf"),
        ("TisaPro-Bold", "otf"),
        ("TisaSansPro-Light", "otf"),
        ("TisaSansPro-Thin", "otf"),
        ("TisaSansPro", "otf"),
        ("TisaSansPro-Medium", "otf"),
        ("TisaSansPro-Bold", "otf")
    ]
    
    static func loadIfNeeded() {
        guard 0 == UIFont.familyNames.filter({ $0.contains("Tisa") }).count else { return }
        
        let bundle = Bundle(for: self)
        
        fonts.forEach {
            let fontPath: String
            if let path = bundle.path(forResource: $0.0, ofType: $0.1) {
                fontPath = path
            } else if let path = bundle.path(forResource: $0.0, ofType: $0.1, inDirectory: "Fonts") {
                fontPath = path
            } else {
                fatalError("Could not find path for \($0.0).\($0.1)!")
            }
            
            let inData = NSData(contentsOfFile: fontPath)
            var error: Unmanaged<CFError>?
            let provider = CGDataProvider(data: inData!)
            if let font = CGFont(provider!) {
                CTFontManagerRegisterGraphicsFont(font, &error)
                if error != nil {
                    assertionFailure(error.debugDescription)
                }
            }
        }
    }
}
