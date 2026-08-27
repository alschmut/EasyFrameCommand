//
//  SupportedDevice.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import Foundation

enum SupportedDevice: CaseIterable {
    case iPhone14ProMax
    case iPadPro
    case iPhoneSE3rdGen

    var layout: Layout {
        switch self {
        case .iPhone14ProMax: .iPhone14ProMax
        case .iPadPro: .iPadPro
        case .iPhoneSE3rdGen: .iPhoneSE3rdGen
        }
    }
    
    static func getFirstMatchingLayout(byPixelSize pixelSize: CGSize) -> Layout? {
        SupportedDevice.allCases.first(where: { device in
            device.layout.allSupportedScreenSizes.contains(pixelSize)
        })?.layout
    }

    /// The layout whose `deviceNameMatches` names this capture's device segment — the part of the
    /// file name before its first `-`.
    ///
    /// Tried before `getFirstMatchingLayout(byPixelSize:)`, because some devices cannot be told
    /// apart by size at all: Apple TV and Vision Pro both capture at exactly 3840 x 2160. A layout
    /// that declares no aliases is unreachable this way and keeps the size lookup it always had,
    /// which is what stops a new layout quietly taking over an old one's screenshots.
    static func layout(forDeviceName name: String) -> Layout? {
        let needle = name.lowercased()
        return allCases.first { device in
            device.layout.deviceNameMatches.contains { $0.lowercased() == needle }
        }?.layout
    }
}

private extension Layout {
    
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
        additionalScreenSizes: [
            .iPadPro13Inch
        ],
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
    static let iPadPro13Inch = CGSize(width: 2064, height: 2752)
    static let iPhoneSE3rdGen = CGSize(width: 750, height: 1334)
}
