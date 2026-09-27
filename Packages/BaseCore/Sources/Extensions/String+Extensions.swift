//
//  String+Extensions.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

public extension String {
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
