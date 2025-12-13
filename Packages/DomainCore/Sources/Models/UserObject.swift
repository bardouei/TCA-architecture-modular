//
//  UserObject.swift
//  Domain
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct UserObject {
    
    public let id: String
    
    public var firstName: String
    public var lastName: String
    
    public let email: String?
    public var phoneNumber: String?
    
    public var isLoggedIn: Bool
    public var isEmailVerified: Bool
    
    public let memberSince: Date
    
    public init(id: String, firstName: String, lastName: String, email: String?, phoneNumber: String?, isLoggedIn: Bool, isEmailVerified: Bool, memberSince: Date) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.isLoggedIn = isLoggedIn
        self.isEmailVerified = isEmailVerified
        self.memberSince = memberSince
    }
}
