//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct Layout: LayoutProvider {
    let size: CGSize
    let deviceFrameOffset: CGSize
    let cornerRadius: CGFloat
    let textInsets: EdgeInsets
    let imageInsets: EdgeInsets
    let titleFontSize: CGFloat
    let textColor: Color

    static let iPhone15ProMax = Self(
        size: CGSize(width: 1290, height: 2796),
        deviceFrameOffset: .zero,
        cornerRadius: 35,
        textInsets: EdgeInsets(top: 72, leading: 120, bottom: 0, trailing: 120),
        imageInsets: EdgeInsets(top: 0, leading: 128, bottom: 72, trailing: 128),
        titleFontSize: 90,
        textColor: .white
    )

    static let iPadPro = Self(
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: .zero,
        cornerRadius: 35,
        textInsets: EdgeInsets(top: 48, leading: 96, bottom: 0, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 150, bottom: -200, trailing: 150),
        titleFontSize: 148,
        textColor: .white
    )
}
