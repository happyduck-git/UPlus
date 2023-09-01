//
//  Log.swift
//  Aftermint
//
//  Created by Hank on 2023/01/27.
//

import Foundation

class LLog {
    private static let tag = ""
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd-HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    enum Priority: String {
        case error = "🟥"
        case warning = "🟨"
        case info = "🟩"
        case debug = "🟦"
        case verbose = "⬜️"
    }
    
    public static func print(
        priority: Priority,
        _ message: Any? = nil,
        fileFullName: String = #file,
        funcName: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let className = fileClassName(fileFullName: fileFullName)
        let logMessage = "\(tag):\(priority.rawValue):\(className).\(funcName)"
        let postfixMessage = ":: (line \(line)) : \(currentThreadToken()) : \(LLog.dateFormatter.string(from: Date()))"
        
        if let message = message {
            Swift.print(logMessage, ":: \(message)", postfixMessage)
        } else {
            Swift.print(logMessage, postfixMessage)
        }
        #endif
    }
    
    public static func e(
        _ message: Any? = nil,
        fileFullName: String = #file,
        funcName: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        print(priority: .error, message, fileFullName: fileFullName, funcName: funcName, line: line)
        #endif
    }
    
    public static func w(
        _ message: Any? = nil,
        fileFullName: String = #file,
        funcName: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        print(priority: .warning, message, fileFullName: fileFullName, funcName: funcName, line: line)
        #endif
    }
    
    public static func i(
        _ message: Any? = nil,
        fileFullName: String = #file,
        funcName: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        print(priority: .info, message, fileFullName: fileFullName, funcName: funcName, line: line)
        #endif
    }
    
    public static func d(
        _ message: Any? = nil,
        fileFullName: String = #file,
        funcName: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        print(priority: .debug, message, fileFullName: fileFullName, funcName: funcName, line: line)
        #endif
    }
    
    public static func v(
        _ message: Any? = nil,
        fileFullName: String = #file,
        funcName: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        print(priority: .verbose, message, fileFullName: fileFullName, funcName: funcName, line: line)
        #endif
    }
    
    private static func fileClassName(fileFullName: String) -> String {
        if let fileName = fileFullName.components(separatedBy: "/").last {
            return fileName.components(separatedBy: ".").first ?? "?"
        }
        return "?"
    }
    
    private static func currentThreadToken() -> String {
        let currentThread = Thread.current
        return "\(String(describing: type(of: currentThread)))#\(String(format: "%x", currentThread.hash))"
    }
}
