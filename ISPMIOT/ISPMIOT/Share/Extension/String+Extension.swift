import UIKit

extension String {

    /// 返回日期(年月日)string
    var timeStampToStrings: String? {
        guard !isEmpty else {
            return nil
        }
        let string = NSString(string: self)
        
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy年MM月dd日"
        
        let date = Date(timeIntervalSince1970: timeSta)
        
        return dfmatter.string(from: date)
    }
}

// 下标截取任意位置的便捷方法
extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
//    func mySubString(to index: Int) -> String {
//        return String(self[..<self.index(self.startIndex, offsetBy: index)])
//    }
//
//    func mySubString(from index: Int) -> String {
//        return String(self[self.index(self.startIndex, offsetBy: index)...])
//    }
}

//不包含后几个字符串的方法
extension String {
    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }
    
    var dropLast: String {
        return dropLast()
    }
}
