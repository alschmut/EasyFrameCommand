//
//  ScreenshotView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ScreenshotView: View {
    let layout: Layout
    let viewModel: ScreenshotViewModel
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

            if let backgroundImage = viewModel.backgroundImage {
                backgroundImage
                    .resizable()
                    .scaledToFit()
            }

            VStack(spacing: 0) {
                Text(viewModel.title)
                    .font(.system(size: titleFontSize))
                    .lineSpacing(titleLineSpacing)
                    .kerning(titleKerning)
                    .fontWeight(.bold)
                    .fontDesign(.default)
                    .foregroundStyle(layout.textColor)
                    .multilineTextAlignment(.center)
                    .padding(layout.textInsets)
                    .frame(height: titleFrameHeight)

                viewModel.framedScreenshots[0]
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 20)
                    .padding(layout.imageInsets)
                    .frame(height: screenshotFrameHeight)
            }
        }
        .environment(\.locale, Locale(identifier: locale))
    }

    var titleFrameHeight: CGFloat {
        layout.size.height * 0.15
    }

    var screenshotFrameHeight: CGFloat {
        layout.size.height - titleFrameHeight
    }

    var titleFontSize: CGFloat {
        layout.titleFontSize ?? layout.size.height / 31
    }

    var titleLineSpacing: CGFloat {
        layout.lineSpacing ?? titleFontSize / 9
    }

    var titleKerning: CGFloat {
        layout.lineSpacing ?? titleFontSize / 30
    }
}

#Preview {
    ScreenshotView(
        layout: .iPhone15ProMax,
        viewModel: ScreenshotViewModel(
            title: "My title",
            backgroundImage: NSImage(),
            framedScreenshots: []
        ),
        locale: "en-GB"
    )
}
