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
    let textInsets: EdgeInsets
    let imageInsets: EdgeInsets
    let titleFontSize: CGFloat
    let textColor: Color

    static let iPhone15ProMax = Self(
        frameImagePath: "Apple iPhone 14 Pro Max Black.png",
        size: CGSize(width: 1290, height: 2796),
        deviceFrameOffset: .zero,
        cornerRadius: 35,
        textInsets: EdgeInsets(top: 0, leading: 100, bottom: 0, trailing: 100),
        imageInsets: EdgeInsets(top: 0, leading: 0, bottom: 80, trailing: 0),
        titleFontSize: 90,
        textColor: .white
    )

    static let iPadPro = Self(
        frameImagePath: "Apple iPhone 14 Pro Max Black.png", // TODO: Fix path
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: .zero,
        cornerRadius: 35,
        textInsets: EdgeInsets(top: 48, leading: 96, bottom: 0, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 150, bottom: -200, trailing: 150),
        titleFontSize: 148,
        textColor: .white
    )

    static let iPhoneSE3rdGen = Self(
        frameImagePath: "Apple iPhone SE Black.png",
        size: CGSize(width: 750, height: 1334),
        deviceFrameOffset: .zero,
        cornerRadius: 35,
        textInsets: EdgeInsets(top: 48, leading: 96, bottom: 0, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 150, bottom: -200, trailing: 150),
        titleFontSize: 148,
        textColor: .white
    )
}
