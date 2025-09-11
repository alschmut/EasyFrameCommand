//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct DeviceFrameView: View {
    let screenshotImage: NSImage
    let deviceNSImage: NSImage
    let deviceScreenSize: CGSize
    let clipCornerRadius: CGFloat
    let devicePositioningOffset: CGSize

    var body: some View {
        ZStack {
            Image(nsImage: screenshotImage)
                .resizable()
                .frame(width: deviceScreenSize.width, height: deviceScreenSize.height)
                .clipShape(RoundedRectangle(cornerRadius: clipCornerRadius))

            Image(nsImage: deviceNSImage)
                .resizable()
                .frame(width: deviceNSImage.pixelSize.width, height: deviceNSImage.pixelSize.height)
                .offset(devicePositioningOffset)
        }
    }
}
