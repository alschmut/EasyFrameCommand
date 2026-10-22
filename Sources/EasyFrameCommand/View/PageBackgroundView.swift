//
//  PageBackgroundView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 02.02.25.
//

import SwiftUI

struct PageBackgroundView: View {
    let pageBackground: PageBackgroundConfig

    var body: some View {
        switch pageBackground.type {
        case .gradient:
            LinearGradient(colors: pageBackground.colors, startPoint: .top, endPoint: .bottom)
        case .mesh:
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: pageBackground.colors)
        }
    }
}

#Preview {
    PageBackgroundView(pageBackground: .defaultGradient)
}
