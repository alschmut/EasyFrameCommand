//
//  ScreenshotView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ScreenshotView: View {
    let layout: Layout
    let content: ViewModel
    let locale: String

    let orange = Color(red: 251 / 255, green: 133 / 255, blue: 0 / 255)

    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: [
                .purple, .purple, .purple,
                orange, orange, .purple,
                orange, orange, orange
            ])

            if let backgroundImage = content.backgroundImage {
                backgroundImage
                    .resizable()
                    .scaledToFit()
            }

            VStack(spacing: 0) {
                Text(content.title)
                    .font(.system(size: layout.titleFontSize))
                    .lineSpacing(10)
                    .kerning(3)
                    .fontWeight(.bold)
                    .fontDesign(.serif)
                    .foregroundStyle(layout.textColor)
                    .multilineTextAlignment(.center)
                    .padding(layout.textInsets)
                    .frame(minHeight: 500)

                content.framedScreenshots[0]
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(layout.imageInsets)
            }
        }
        .environment(\.locale, Locale(identifier: locale))
    }
}

#Preview {
    ScreenshotView(
        layout: .iPhone15ProMax,
        content: ViewModel(
            title: "My title",
            backgroundImage: NSImage(),
            framedScreenshots: []
        ),
        locale: "en-GB"
    )
}
