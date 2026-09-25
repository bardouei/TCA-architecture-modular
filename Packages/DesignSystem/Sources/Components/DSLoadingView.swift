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
        ProgressView {
            Text("Loading…")
        }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}
