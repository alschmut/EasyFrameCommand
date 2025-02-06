//
//  ScreenshotViewModel.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ScreenshotViewModel {
    let pageIndex: Int
    let title: String
    let description: String
    let framedScreenshots: [Image]

    init(
        pageIndex: Int,
        title: String,
        description: String,
        framedScreenshots: [NSImage]
    ) {
        self.pageIndex = pageIndex
        self.title = title
        self.description = description
        self.framedScreenshots = framedScreenshots.map { Image(nsImage: $0) }
    }
}
