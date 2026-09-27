//
//  DSCard.swift
//  DesignSystem
//
//  Created by baner on 1/3/26.
//

import SwiftUI

public struct DSCard<Content: View>: View {
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(DSSpacing.md)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
    }
}
