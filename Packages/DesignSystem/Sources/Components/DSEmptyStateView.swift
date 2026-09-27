//
//  DSEmptyStateView.swift
//  DesignSystem
//
//  Created by baner on 1/3/26.
//

import SwiftUI

public struct DSEmptyStateView: View {
    
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    
    public init(
        title: LocalizedStringResource,
        description: LocalizedStringResource
    ) {
        self.title = title
        self.description = description
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(DSColor.secondary)
            
            Text(title)
                .font(DSTypography.headline)
            
            Text(description)
                .font(DSTypography.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
