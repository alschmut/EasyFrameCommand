//
//  NSImage+PixelSize.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 30.01.25.
//

import SwiftUI

extension NSImage {

    var pixelSize: CGSize {
        let representation = representations[0]
        return CGSize(width: representation.pixelsWide, height: representation.pixelsHigh)
    }
}
