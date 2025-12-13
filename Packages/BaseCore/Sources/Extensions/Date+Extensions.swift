//
//  Date+Extensions.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

public extension Date {
    static var nowTimestamp: TimeInterval {
        Date().timeIntervalSince1970
    }
}
