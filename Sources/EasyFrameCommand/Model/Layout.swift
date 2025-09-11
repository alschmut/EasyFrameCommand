//
//  Layout.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct Layout {
    let deviceImageName: String
    let deviceScreenSize: CGSize
    var additionalScreenSizes: [CGSize] = []
    let devicePositioningOffset: CGSize
    let clipCornerRadius: CGFloat
    
    func relative(_ value: CGFloat) -> CGFloat {
        deviceScreenSize.height / 2796 * value
    }
    
    var allSupportedScreenSizes: [CGSize] {
        [deviceScreenSize] + additionalScreenSizes
    }
}
