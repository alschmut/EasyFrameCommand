//
//  ImageData.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ImageData: Identifiable, Sendable {
    let id = UUID()
    let image: Image
    let size: CGSize
    var offset: CGSize = .zero

    init(nsImage: NSImage, offset: CGSize = .zero) {
        image = Image(nsImage: nsImage)
        size = nsImage.size
        self.offset = offset
    }
}
