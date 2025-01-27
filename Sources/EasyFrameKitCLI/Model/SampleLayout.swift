//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct SampleLayout: LayoutProvider {
    let size: CGSize
    let deviceFrameOffset: CGSize
    let textInsets: EdgeInsets
    let imageInsets: EdgeInsets
    let keywordFontSize: CGFloat
    let titleFontSize: CGFloat
    let textGap: CGFloat
    let textColor: Color
    let backgroundColor: Color

    private static let defaultBackgroundColor = Color(red: 251 / 255, green: 133 / 255, blue: 0 / 255)

    static let iPhone15ProMax = Self(
        size: CGSize(width: 1290, height: 2796),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 72, leading: 120, bottom: 0, trailing: 120),
        imageInsets: EdgeInsets(top: 0, leading: 128, bottom: 72, trailing: 128),
        keywordFontSize: 148,
        titleFontSize: 72,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )

    static let iPadPro = Self(
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 48, leading: 96, bottom: 0, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 150, bottom: -200, trailing: 150),
        keywordFontSize: 148,
        titleFontSize: 72,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )
}
