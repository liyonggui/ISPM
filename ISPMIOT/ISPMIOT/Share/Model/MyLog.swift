import UIKit

/// 直接打印出内容
///
/// - Parameter message: 打印的内容
func MyPrint<T>(_ message : T) {
    
    #if DEBUG
    print("\(message)")
    #endif
}

/// 打印内容，并包含类名和打印所在行数
///
/// - Parameters:
///   - message: 打印消息
///   - file: 打印所属类
///   - lineNumber: 打印语句所在行数
func MyPrint<T>(_ message : T, file : String = #file, lineNumber : Int = #line) {
    
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):line:\(lineNumber)]- \(message)")
    #endif
}
