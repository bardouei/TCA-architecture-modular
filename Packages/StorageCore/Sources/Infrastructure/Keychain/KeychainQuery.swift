//
//  KeychainQuery.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation
import Security

struct KeychainQuery {
    let service: String
    let account: String

    var base: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
