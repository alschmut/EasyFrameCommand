//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct DeviceFrameView: View {
    let screenshotImage: NSImage
    let frameImage: NSImage
    let frameScreenSize: CGSize
    let screenshotCornerRadius: CGFloat
    let frameOffset: CGSize

    var body: some View {
        ZStack {
            Image(nsImage: screenshotImage)
                .resizable()
                .frame(width: frameScreenSize.width, height: frameScreenSize.height)
                .clipShape(RoundedRectangle(cornerRadius: screenshotCornerRadius))

            Image(nsImage: frameImage)
                .resizable()
                .frame(width: frameImage.pixelSize.width, height: frameImage.pixelSize.height)
                .offset(frameOffset)
        }
    }
}
