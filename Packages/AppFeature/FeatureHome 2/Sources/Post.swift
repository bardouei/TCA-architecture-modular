//
//  Post.swift
//  FeatureHome
//
//  Created by baner on 12/13/25.
//

import Foundation

public struct Post: Identifiable, Codable, Equatable {
  public let id: Int
  public let title: String
  public let body: String
}
