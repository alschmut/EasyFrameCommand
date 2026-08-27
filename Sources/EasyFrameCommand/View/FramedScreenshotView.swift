//
//  FramedScreenshotView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct FramedScreenshotView: View {
    let screenshotNSImage: NSImage
    let deviceNSImage: NSImage
    let deviceScreenSize: CGSize
    let clipCornerRadius: CGFloat
    let devicePositioningOffset: CGSize
    /// The screen cut-out in the bezel art's own coordinates, or `nil` to centre the screenshot.
    /// See `Layout.screenFrame`.
    let screenFrame: CGRect?

    /// The bezel art's true pixel size.
    ///
    /// **Not `deviceNSImage.size`.** `NSImage.size` is in points, derived from the file's DPI, and
    /// art published by a device vendor is often not 72 dpi — 144, 216 and 300 all turn up. A
    /// 1470 px wide render at 216 dpi reports a `size.width` of 490, and laying the composite out at
    /// that number renders the whole thing at a third of its intended size inside a frame that looks
    /// perfectly correct.
    private var artPixelSize: CGSize { deviceNSImage.pixelSize }

    var body: some View {
        ZStack(alignment: .topLeading) {
            screenshot

            Image(nsImage: deviceNSImage)
                .resizable()
                .frame(width: artPixelSize.width, height: artPixelSize.height)
                .offset(devicePositioningOffset)
        }
        // Pinned rather than derived. A centred `ZStack` takes its size from the bezel child; a
        // top-leading one whose screenshot is pushed around by `.offset` does not, and
        // `ImageRenderer` renders the content's own size.
        .frame(width: artPixelSize.width, height: artPixelSize.height)
    }

    @ViewBuilder private var screenshot: some View {
        if let screenFrame {
            // Positioned. Art whose cut-out is centred lands in the same place either way; art whose
            // cut-out is not — a television with a set-top box and a remote beside it — does not.
            Image(nsImage: screenshotNSImage)
                .resizable()
                .frame(width: screenFrame.width, height: screenFrame.height)
                // Belt-and-braces: the bezel is composited *over* this, so the art's own alpha is
                // what actually shapes the screen. The clip only bites if it is set larger than the
                // hole's own corner, which would cut into visible screen.
                .clipShape(RoundedRectangle(cornerRadius: clipCornerRadius))
                .offset(x: screenFrame.minX, y: screenFrame.minY)
        } else {
            // Centred in the art — the path every layout took before `screenFrame` existed.
            Image(nsImage: screenshotNSImage)
                .resizable()
                .frame(width: deviceScreenSize.width, height: deviceScreenSize.height)
                .clipShape(RoundedRectangle(cornerRadius: clipCornerRadius))
                .frame(width: artPixelSize.width, height: artPixelSize.height)
        }
    }
}
