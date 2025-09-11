//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct Layout {
    let deviceImageName: String
    let frameScreenSize: CGSize
    var additionalScreenshotSizes: [CGSize] = []
    let deviceFrameOffset: CGSize
    let cornerRadius: CGFloat

    func relative(_ value: CGFloat) -> CGFloat {
        frameScreenSize.height / 2796 * value
    }
    
    var allScreenSizes: [CGSize] {
        [frameScreenSize] + additionalScreenshotSizes
    }
    
    /// The iPhone 14 Pro Max frame is also used for screenshots made with an iPhone 15, 16 and 17 Pro Max
    /// The `DeviceFrameView` will show a slightly downscaled version of the screenshot
    static let iPhone14ProMax = Self(
        deviceImageName: "Apple iPhone 14 Pro Max Black.png",
        frameScreenSize: .iPhone14ProMax,
        additionalScreenshotSizes: [
            .iPhone15ProMax,
            .iPhone16ProMax,
            .iPhone17ProMax
        ],
        deviceFrameOffset: .init(width: 0, height: 2),
        cornerRadius: 35
    )

    static let iPadPro = Self(
        deviceImageName: "Apple iPad Pro (12.9-inch) (4th generation) Space Gray.png",
        frameScreenSize: .iPadPro6thGen13Inch,
        deviceFrameOffset: .init(width: 2, height: 0),
        cornerRadius: 35
    )

    static let iPhoneSE3rdGen = Self(
        deviceImageName: "Apple iPhone SE Black.png",
        frameScreenSize: .iPhoneSE3rdGen,
        deviceFrameOffset: .init(width: 0, height: 2),
        cornerRadius: 0
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
