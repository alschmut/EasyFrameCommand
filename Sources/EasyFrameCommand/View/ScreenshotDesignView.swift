//
//  ScreenshotDesignView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ScreenshotDesignView: View {
    let layout: Layout
    let locale: String
    let pageIndex: Int
    let title: String
    let description: String
    let framedScreenshotNSImage: NSImage

    var body: some View {
        ZStack {
            CustomBackgroundView(pageIndex: pageIndex)

            VStack(spacing: 0) {
                VStack(spacing: layout.relative(37)) {
                    let titleFontSize: CGFloat = 110
                    Text(title)
                        .font(.system(size: layout.relative(titleFontSize)))
                        .lineSpacing(layout.relative(titleFontSize) / 7)
                        .kerning(layout.relative(titleFontSize) / 30)
                        .fontWeight(.bold)

                    if !description.isEmpty {
                        let descriptionFontSize: CGFloat = 75
                        Text(description)
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

                Image(nsImage: framedScreenshotNSImage)
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
        layout.deviceScreenSize.height * 0.2
    }

    private var screenshotFrameHeight: CGFloat {
        layout.deviceScreenSize.height - titleFrameHeight
    }
}

#Preview {
    ScreenshotDesignView(
        layout: SupportedDevice.iPhone14ProMax.layout,
        locale: "en-GB",
        pageIndex: 0,
        title: "My title",
        description: "My description",
        framedScreenshotNSImage: NSImage()
    )
}
