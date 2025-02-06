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

    var body: some View {
        ZStack {
            CustomBackgroundView(pageIndex: viewModel.pageIndex)

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
                .foregroundStyle(.white)
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
        layout.screenshotSize.height * 0.2
    }

    private var screenshotFrameHeight: CGFloat {
        layout.screenshotSize.height - titleFrameHeight
    }
}

#Preview {
    ScreenshotView(
        layout: .iPhone15ProMax,
        viewModel: ScreenshotViewModel(
            pageIndex: 0,
            title: "My title",
            description: "My description",
            framedScreenshots: []
        ),
        locale: "en-GB"
    )
}
