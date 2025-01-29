//
//  FrameData.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct FrameData {
    let screenshotImage: Image
    let screenshotSize: CGSize
    let screenshotCornerRadius: CGFloat

    let frameImage: Image
    let frameSize: CGSize
    let frameOffset: CGSize

    init(
        screenshotImage: NSImage,
        frameImage: NSImage,
        screenshotCornerRadius: CGFloat,
        frameOffset: CGSize
    ) {
        self.screenshotImage = Image(nsImage: screenshotImage)
        self.screenshotSize = screenshotImage.pixelSize
        self.screenshotCornerRadius = screenshotCornerRadius

        self.frameImage = Image(nsImage: frameImage)
        self.frameSize = frameImage.pixelSize
        self.frameOffset = frameOffset
    }
}

extension NSImage {

    var pixelSize: CGSize {
        let representation = representations[0]
        return CGSize(width: representation.pixelsWide, height: representation.pixelsHigh)
    }
}

