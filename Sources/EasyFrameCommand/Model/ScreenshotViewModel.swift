//
//  ScreenshotViewModel.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ScreenshotViewModel {
    let title: String
    let description: String
    let backgroundImage: Image?
    let framedScreenshots: [Image]

    init(title: String, description: String, backgroundImage: NSImage? = nil, framedScreenshots: [NSImage]) {
        self.title = title
        self.description = description
        self.backgroundImage = backgroundImage.map { Image(nsImage: $0) }
        self.framedScreenshots = framedScreenshots.map { Image(nsImage: $0) }
    }
}
