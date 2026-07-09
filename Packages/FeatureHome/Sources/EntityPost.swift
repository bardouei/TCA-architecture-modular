//
//  Post.swift
//  FeatureHome
//
//  Created by baner on 12/13/25.
//

import Foundation

public struct EntityPost: Codable, Equatable, Sendable, Identifiable {
    public let id: Int
    public let title: String
    public let body: String

    public init(id: Int, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
    }
}
