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
                VStack(spacing: layout.relative(37)) {
                    Text(viewModel.title)
                        .font(.system(size: layout.relative(96)))
                        .lineSpacing(layout.relative(96) / 7)
                        .kerning(layout.relative(96) / 30)
                        .fontWeight(.bold)

                    if !viewModel.description.isEmpty {
                        Text(viewModel.description)
                            .font(.system(size: layout.relative(62)))
                            .lineSpacing(layout.relative(62) / 7)
                            .kerning(layout.relative(62) / 30)
                            .fontWeight(.light)
                            .padding(.horizontal, layout.relative(35))
                    }
                }
                .foregroundStyle(layout.textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, layout.relative(15))
                .frame(height: titleFrameHeight)

                viewModel.framedScreenshots[0]
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 20)
                    .padding(.bottom, layout.relative(80))
                    .frame(height: screenshotFrameHeight)
            }
        }
        .environment(\.locale, Locale(identifier: locale))
    }

    private var titleFrameHeight: CGFloat {
        layout.size.height * 0.2
    }

    private var screenshotFrameHeight: CGFloat {
        layout.size.height - titleFrameHeight
    }
}

#Preview {
    ScreenshotView(
        layout: .iPhone15ProMax,
        viewModel: ScreenshotViewModel(
            title: "My title",
            description: "My description",
            backgroundImage: NSImage(),
            framedScreenshots: []
        ),
        locale: "en-GB"
    )
}
