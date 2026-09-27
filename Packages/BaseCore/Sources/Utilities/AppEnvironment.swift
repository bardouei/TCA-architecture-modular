//
//  AppEnvironment.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

public enum AppEnvironment: String, CaseIterable, Codable, Sendable {
    case development
    case staging
    case production

    public var isProduction: Bool {
        self == .production
    }

    public var enablesVerboseLogging: Bool {
        self != .production
    }
}
