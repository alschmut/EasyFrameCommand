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
    let offset: CGSize
    let cornerRadius: CGFloat

    init(nsImage: NSImage, offset: CGSize = .zero, cornerRadius: CGFloat = 0) {
        image = Image(nsImage: nsImage)
        let imageRepresentation = nsImage.representations[0]
        size = CGSize(width: imageRepresentation.pixelsWide, height: imageRepresentation.pixelsHigh)
        self.offset = offset
        self.cornerRadius = cornerRadius
    }
}
