//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct DeviceFrameView: View {
    let screenshotImage: ImageData
    let frameImage: ImageData

    var body: some View {
        ZStack {
            screenshotImage.image
                .resizable()
                .frame(width: screenshotImage.size.width, height: screenshotImage.size.height)
                .clipShape(RoundedRectangle(cornerRadius: screenshotImage.cornerRadius))
                .offset(screenshotImage.offset)

            frameImage.image
                .resizable()
                .frame(width: frameImage.size.width, height: frameImage.size.height)
        }
    }
}
