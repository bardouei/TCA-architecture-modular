//
//  Optional+Extensions.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

public extension Optional {
    var isNil: Bool {
        self == nil
    }

    var isNotNil: Bool {
        self != nil
    }
}
