//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct SampleContent {
    let title: String
    let backgroundImage: Image?
    let framedScreenshots: [Image]

    init(title: String, backgroundImage: NSImage? = nil, framedScreenshots: [NSImage]) {
        self.title = title
        self.backgroundImage = backgroundImage.map { Image(nsImage: $0) }
        self.framedScreenshots = framedScreenshots.map { Image(nsImage: $0) }
    }
}
