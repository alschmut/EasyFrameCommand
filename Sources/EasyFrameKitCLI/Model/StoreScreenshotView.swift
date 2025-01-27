//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

protocol StoreScreenshotView: View {
    associatedtype Layout: LayoutProvider
    associatedtype Content

    var layout: Layout { get }
    var content: Content { get }
}

extension StoreScreenshotView where Self.Layout == SampleLayout {
    var keywordFont: Font { Font.system(size: layout.keywordFontSize, weight: .bold, design: .default) }
    var titleFont: Font { Font.system(size: layout.titleFontSize, weight: .regular, design: .default) }
}
