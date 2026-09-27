//
//  Logger.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

public struct Logger: Sendable {
    private let minimumLevel: LogLevel
    private let destination: any LogDestination

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "BaseCore",
        category: String = "General",
        minimumLevel: LogLevel = .debug
    ) {
        self.init(
            minimumLevel: minimumLevel,
            destination: OSLogDestination(subsystem: subsystem, category: category)
        )
    }

    public init(
        minimumLevel: LogLevel = .debug,
        destination: any LogDestination
    ) {
        self.minimumLevel = minimumLevel
        self.destination = destination
    }

    public func log(
        _ level: LogLevel = .debug,
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= minimumLevel else { return }

        destination.write(
            LogRecord(
                level: level,
                message: message(),
                file: file,
                function: function,
                line: line
            )
        )
    }

    /// Compatibility entry point for existing call sites.
    public static func log(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.debug, message(), file: file, function: function, line: line)
    }

    private static let shared = Logger()
}
