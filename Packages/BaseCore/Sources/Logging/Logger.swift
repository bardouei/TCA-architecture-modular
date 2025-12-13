//
//  Logger.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

public enum Logger {

    public static func log(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("🧩 [\(fileName):\(line)] \(function) → \(message)")
        #endif
    }
}
