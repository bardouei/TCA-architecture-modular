//
//  Collection+Extensions.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

public extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }

    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
