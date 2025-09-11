//
//  DeviceFrameView.swift
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
    
    /// The iPhone 14 Pro Max frame is also used for screenshots made with an iPhone 15, 16 and 17 Pro Max
    /// The `FramedScreenshotView` will show a slightly downscaled version of the screenshot
    static let iPhone14ProMax = Self(
        deviceImageName: "Apple iPhone 14 Pro Max Black.png",
        deviceScreenSize: .iPhone14ProMax,
        additionalScreenSizes: [
            .iPhone15ProMax,
            .iPhone16ProMax,
            .iPhone17ProMax
        ],
        devicePositioningOffset: .init(width: 0, height: 2),
        clipCornerRadius: 35
    )

    static let iPadPro = Self(
        deviceImageName: "Apple iPad Pro (12.9-inch) (4th generation) Space Gray.png",
        deviceScreenSize: .iPadPro6thGen13Inch,
        devicePositioningOffset: .init(width: 2, height: 0),
        clipCornerRadius: 35
    )

    static let iPhoneSE3rdGen = Self(
        deviceImageName: "Apple iPhone SE Black.png",
        deviceScreenSize: .iPhoneSE3rdGen,
        devicePositioningOffset: .init(width: 0, height: 2),
        clipCornerRadius: 0
    )
}

private extension CGSize {
    static let iPhone17ProMax = CGSize(width: 1320, height: 2868)
    static let iPhone16ProMax = CGSize(width: 1320, height: 2868)
    static let iPhone15ProMax = CGSize(width: 1290, height: 2796)
    static let iPhone14ProMax = CGSize(width: 1290, height: 2796)
    static let iPadPro6thGen13Inch = CGSize(width: 2048, height: 2732)
    static let iPhoneSE3rdGen = CGSize(width: 750, height: 1334)
}
