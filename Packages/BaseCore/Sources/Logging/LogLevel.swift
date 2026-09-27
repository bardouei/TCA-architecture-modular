//
//  LogLevel.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

public enum LogLevel: Int, CaseIterable, Comparable, Sendable {
    case trace
    case debug
    case info
    case notice
    case warning
    case error
    case critical

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
