//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct DeviceFrameView: View {
    let frameData: FrameData

    var body: some View {
        ZStack {
            frameData.screenshotImage
                .resizable()
                .frame(width: frameData.screenshotSize.width, height: frameData.screenshotSize.height)
                .clipShape(RoundedRectangle(cornerRadius: frameData.screenshotCornerRadius))

            frameData.frameImage
                .resizable()
                .frame(width: frameData.frameSize.width, height: frameData.frameSize.height)
                .offset(frameData.frameOffset)
        }
    }
}
