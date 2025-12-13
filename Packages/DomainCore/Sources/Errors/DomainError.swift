//
//  DomainError.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

public enum DomainError: Error, Equatable {
    case userNotFound
    case invalidEmail
    case invalidInput
}
