//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct DeviceFrameView: View {
    let images: [ImageData]

    var body: some View {
        ZStack {
            ForEach(images) { image in
                image.image
                    .resizable()
                    .frame(width: image.size.width, height: image.size.height)
                    .offset(image.offset)
            }
        }
    }
}
