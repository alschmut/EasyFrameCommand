//
//  ScreensConfiguration.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct EasyFrameConfig: Decodable {
    let appStoreScreens: [ScreenConfig]
}

struct ScreenConfig: Decodable {
    let languages: [LanguageConfig]
    let screenshots: [String]
}

struct LanguageConfig: Decodable {
    let locale: String
    let title: String
}
