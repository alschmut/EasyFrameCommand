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
    /// Renders the artwork as a rounded, shadowed card under a taller caption band, rather than as
    /// a device standing on the page.
    ///
    /// A frameless page asks for it: its artwork is a bare capture rather than a device, and a
    /// landscape one at that, so it cannot use the height an upright phone does and the extra space
    /// would otherwise sit empty above it.
    let rendersAsCard: Bool

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

                artwork
                    .frame(height: screenshotFrameHeight)
            }
        }
        .environment(\.locale, Locale(identifier: locale))
    }

    @ViewBuilder private var artwork: some View {
        if rendersAsCard {
            Image(nsImage: framedScreenshotNSImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: layout.relative(48)))
                .shadow(color: .black.opacity(0.35), radius: layout.relative(28), y: layout.relative(10))
                .padding(.horizontal, layout.relative(36))
                // The same bottom inset a device page gets, and load-bearing here. A landscape card
                // in an artwork band taller than it is wide is always *height*-limited: it fills the
                // band exactly, and its bottom edge lands flush on the canvas edge with the shadow
                // clipped off.
                .padding(.bottom, layout.relative(80))
        } else {
            Image(nsImage: framedScreenshotNSImage)
                .resizable()
                .scaledToFit()
                .shadow(radius: layout.relative(20))
                .padding(.bottom, layout.relative(80))
        }
    }

    /// A card gets a taller caption band than a device does, for the reason `rendersAsCard` records.
    /// `0.2` is the height every page had before frameless pages existed, and device pages keep it.
    private var titleFrameHeight: CGFloat {
        layout.deviceScreenSize.height * (rendersAsCard ? 0.28 : 0.2)
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
        framedScreenshotNSImage: NSImage(),
        rendersAsCard: false
    )
}
