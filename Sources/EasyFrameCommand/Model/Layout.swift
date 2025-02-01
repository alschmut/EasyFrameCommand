//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct Layout {
    let frameImagePath: String
    let size: CGSize
    let deviceFrameOffset: CGSize
    let cornerRadius: CGFloat
    let textColor: Color

    func relative(_ value: CGFloat) -> CGFloat {
        size.height / 2796 * value
    }

    static let iPhone15ProMax = Self(
        frameImagePath: "Apple iPhone 14 Pro Max Black.png",
        size: CGSize(width: 1290, height: 2796),
        deviceFrameOffset: .init(width: 0, height: 2),
        cornerRadius: 35,
        textColor: .white
    )

    static let iPadPro = Self(
        frameImagePath: "Apple iPad Pro (12.9-inch) (4th generation) Space Gray.png",
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: .init(width: 2, height: 0),
        cornerRadius: 35,
        textColor: .white
    )

    static let iPhoneSE3rdGen = Self(
        frameImagePath: "Apple iPhone SE Black.png",
        size: CGSize(width: 750, height: 1334),
        deviceFrameOffset: .init(width: 0, height: 2),
        cornerRadius: 0,
        textColor: .white
    )
}
