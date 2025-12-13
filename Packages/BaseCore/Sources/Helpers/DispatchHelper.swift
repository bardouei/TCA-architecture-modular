//
//  DispatchHelper.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

public enum DispatchHelper {

    public static func main(
        _ block: @Sendable @escaping () -> Void
    ) {
        Task { @MainActor in
            block()
        }
    }
}
