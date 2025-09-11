//
//  FrameViewModel.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct FrameViewModel {
    let screenshotImage: Image
    let screenshotSize: CGSize
    let screenshotCornerRadius: CGFloat

    let frameImage: Image
    let frameSize: CGSize
    let frameOffset: CGSize

    init(
        screenshotImage: NSImage,
        frameImage: NSImage,
        frameScreenSize: CGSize,
        screenshotCornerRadius: CGFloat,
        frameOffset: CGSize
    ) {
        self.screenshotImage = Image(nsImage: screenshotImage)
        self.screenshotSize = frameScreenSize // screenshotImage.pixelSize
        self.screenshotCornerRadius = screenshotCornerRadius

        self.frameImage = Image(nsImage: frameImage)
        self.frameSize = frameImage.pixelSize
        self.frameOffset = frameOffset
    }
}

