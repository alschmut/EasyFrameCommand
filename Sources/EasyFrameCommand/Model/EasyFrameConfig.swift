//
//  ScreensConfiguration.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct EasyFrameConfig: Decodable {
    let pageBackgrounds: [PageBackgroundConfig]?
    let pages: [PageConfig]
}

struct PageConfig: Decodable {
    let languagesConfig: [LanguageConfig]
    let screenshotSuffix: String
    let pageBackgroundId: String?

    enum CodingKeys: String, CodingKey {
        case languagesConfig = "languages"
        case screenshotSuffix = "screenshot"
        case pageBackgroundId
    }
}

struct LanguageConfig: Decodable {
    let locale: String
    let title: String
    let description: String?
}

struct PageBackgroundConfig: Decodable {
    let id: String
    let type: BackgroundType
    let hexColors: [String]

    static let defaultGradient = PageBackgroundConfig(id: "default", type: .gradient, hexColors: ["#EEF1F2", "#D5D8D9"])

    /// Invalid hex colors are skipped
    var colors: [Color] {
        hexColors.compactMap(Color.init(hex:))
    }

    var isValidColorCount: Bool {
        switch type {
        case .gradient: !colors.isEmpty
        case .mesh: colors.count == 9
        }
    }

    enum BackgroundType: String, Decodable {
        /// top to bottom, a single color is a solid background
        case gradient
        /// 3x3 grid from top left to bottom right, requires exactly 9 colors
        case mesh
    }
}
