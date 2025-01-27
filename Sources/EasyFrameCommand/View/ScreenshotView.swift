//
//  ScreenshotView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct ScreenshotView: View {
    let layout: Layout
    let content: ViewModel
    let isRightToLeft: Bool
    let locale: String

    var body: some View {
        ZStack {
            Color(red: 251 / 255, green: 133 / 255, blue: 0 / 255)

            if let backgroundImage = content.backgroundImage {
                backgroundImage
                    .resizable()
                    .scaledToFit()
            }

            content.framedScreenshots[0]
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(layout.imageInsets)

            Text(content.title)
                .font(.system(size: layout.titleFontSize))
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(layout.textColor)
                .multilineTextAlignment(.center)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(layout.textInsets)
        }
        .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
        .environment(\.locale, Locale(identifier: locale))
    }
}

#Preview {
    ScreenshotView(
        layout: .iPhone15ProMax,
        content: ViewModel(
            title: "My title",
            backgroundImage: NSImage(),
            framedScreenshots: []
        ),
        isRightToLeft: false,
        locale: "en-GB"
    )
}
