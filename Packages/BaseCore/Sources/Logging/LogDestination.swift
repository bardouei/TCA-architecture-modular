//
//  LogDestination.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation
import os

public struct LogRecord: Sendable {
    public let level: LogLevel
    public let message: String
    public let file: String
    public let function: String
    public let line: Int

    public init(
        level: LogLevel,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        self.level = level
        self.message = message
        self.file = file
        self.function = function
        self.line = line
    }
}

public protocol LogDestination: Sendable {
    func write(_ record: LogRecord)
}

public struct OSLogDestination: LogDestination {
    private let logger: os.Logger

    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func write(_ record: LogRecord) {
        let message = "[\(record.file):\(record.line)] \(record.function) → \(record.message)"

        switch record.level {
        case .trace, .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .notice:
            logger.notice("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .critical:
            logger.critical("\(message, privacy: .public)")
        }
    }
}
