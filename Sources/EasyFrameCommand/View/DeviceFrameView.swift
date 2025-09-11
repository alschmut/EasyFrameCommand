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
    let deviceScreenSize: CGSize
    let clipCornerRadius: CGFloat
    let frameOffset: CGSize

    var body: some View {
        ZStack {
            Image(nsImage: screenshotImage)
                .resizable()
                .frame(width: deviceScreenSize.width, height: deviceScreenSize.height)
                .clipShape(RoundedRectangle(cornerRadius: clipCornerRadius))

            Image(nsImage: frameImage)
                .resizable()
                .frame(width: frameImage.pixelSize.width, height: frameImage.pixelSize.height)
                .offset(frameOffset)
        }
    }
}
