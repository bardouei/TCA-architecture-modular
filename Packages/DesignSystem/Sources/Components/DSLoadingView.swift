//
//  DSLoadingView.swift
//  DesignSystem
//
//  Created by baner on 1/3/26.
//

import SwiftUI

public struct DSLoadingView: View {

    public init() {}

    public var body: some View {
        ProgressView("Loading...")
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(DSRadius.sm)
    }
}
