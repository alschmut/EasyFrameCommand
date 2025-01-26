import SwiftUI
import FrameKit

extension SampleLayout {
    static let defaultBackgroundColor = Color(red: 251 / 255, green: 133 / 255, blue: 0 / 255)

    static let iPhone65 = Self(
        size: CGSize(width: 1242, height: 2688),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 72, leading: 120, bottom: 0, trailing: 120),
        imageInsets: EdgeInsets(top: 0, leading: 128, bottom: 72, trailing: 128),
        keywordFontSize: 148,
        titleFontSize: 72,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )

    static let iPhone14Pro = Self(
        size: CGSize(width: 1179, height: 2556),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 72, leading: 120, bottom: 0, trailing: 120),
        imageInsets: EdgeInsets(top: 0, leading: 128, bottom: 72, trailing: 128),
        keywordFontSize: 148,
        titleFontSize: 72,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )

    static let iPhone55 = Self(
        size: CGSize(width: 1242, height: 2208),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 36, leading: 96, bottom: 0, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 84, bottom: -500, trailing: 84),
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

    static let iPadPro3rdGen = Self(
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: CGSize(width: -1, height: 1),
        textInsets: EdgeInsets(top: 48, leading: 96, bottom: 0, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 96, bottom: -200, trailing: 96),
        keywordFontSize: 148,
        titleFontSize: 72,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )
}

extension SampleLayout {
    static let iPhone65Hero = Self(
        size: CGSize(width: 1242, height: 2688),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 0, leading: 96, bottom: 240, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 84, bottom: 96, trailing: 84),
        keywordFontSize: 108,
        titleFontSize: 0,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )

    static let iPhone55Hero = Self(
        size: CGSize(width: 1242, height: 2208),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 0, leading: 96, bottom: 240, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 84, bottom: 96, trailing: 84),
        keywordFontSize: 108,
        titleFontSize: 0,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )

    static let iPadProHero = Self(
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: .zero,
        textInsets: EdgeInsets(top: 0, leading: 96, bottom: 240, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 150, bottom: 148, trailing: 150),
        keywordFontSize: 108,
        titleFontSize: 0,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )

    static let iPadPro3rdGenHero = Self(
        size: CGSize(width: 2048, height: 2732),
        deviceFrameOffset: CGSize(width: -1, height: 1),
        textInsets: EdgeInsets(top: 0, leading: 96, bottom: 240, trailing: 96),
        imageInsets: EdgeInsets(top: 0, leading: 96, bottom: 148, trailing: 96),
        keywordFontSize: 108,
        titleFontSize: 0,
        textGap: 24,
        textColor: .white,
        backgroundColor: defaultBackgroundColor
    )
}
