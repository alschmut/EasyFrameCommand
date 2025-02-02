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
    let blue = Color(red: 30 / 255, green: 85 / 255, blue: 125 / 255)
    let purple = Color.purple

    var colors: [Color] {
        if viewModel.pageIndex % 3 == 0 {
            return [
                purple, purple, blue,
                orange, orange, purple,
                orange, orange, orange
            ]
        } else if viewModel.pageIndex % 3 == 1 {
            return [
                blue, purple, purple,
                purple, orange, blue,
                orange, orange, orange
            ]
        } else {
            return [
                purple, purple, purple,
                blue, orange, orange,
                orange, orange, orange
            ]
        }
    }

    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: colors)

            if let backgroundImage = viewModel.backgroundImage {
                backgroundImage
                    .resizable()
                    .scaledToFit()
            }

            VStack(spacing: 0) {
                VStack(spacing: layout.relative(37)) {
                    let titleFontSize: CGFloat = 110
                    Text(viewModel.title)
                        .font(.system(size: layout.relative(titleFontSize)))
                        .lineSpacing(layout.relative(titleFontSize) / 7)
                        .kerning(layout.relative(titleFontSize) / 30)
                        .fontWeight(.bold)

                    if !viewModel.description.isEmpty {
                        let descriptionFontSize: CGFloat = 75
                        Text(viewModel.description)
                            .font(.system(size: layout.relative(descriptionFontSize)))
                            .lineSpacing(layout.relative(descriptionFontSize) / 7)
                            .kerning(layout.relative(descriptionFontSize) / 30)
                            .fontWeight(.light)
                            .padding(.horizontal, layout.relative(35))
                    }
                }
                .foregroundStyle(layout.textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, layout.relative(10))
                .frame(height: titleFrameHeight)

                viewModel.framedScreenshots[0]
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: layout.relative(20))
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
            pageIndex: 0,
            title: "My title",
            description: "My description",
            backgroundImage: NSImage(),
            framedScreenshots: []
        ),
        locale: "en-GB"
    )
}
