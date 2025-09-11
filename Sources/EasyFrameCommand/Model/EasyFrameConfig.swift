//
//  ScreensConfiguration.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct EasyFrameConfig: Decodable {
    let pages: [PageConfig]
}

struct PageConfig: Decodable {
    let languagesConfig: [LanguageConfig]
    let screenshotSuffix: String

    enum CodingKeys: String, CodingKey {
        case languagesConfig = "languages"
        case screenshotSuffix = "screenshot"
    }
}

struct LanguageConfig: Decodable {
    let locale: String
    let title: String
    let description: String
}
