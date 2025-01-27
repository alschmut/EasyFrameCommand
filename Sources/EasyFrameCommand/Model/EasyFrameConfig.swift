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

    static func myConfiguration() -> [ScreenConfig] {
        [
            ScreenConfig(
                languages: [
                    LanguageConfig(locale: "en-GB", title: "Document your crying moments")
                ],
                screenshots: ["1-tear-tales-calendar"]
            ),
            ScreenConfig(
                languages: [
                    LanguageConfig(locale: "en-GB", title: "List")
                ],
                screenshots: ["2-tear-tales-list"]
            ),
            ScreenConfig(
                languages: [
                    LanguageConfig(locale: "en-GB", title: "Statistics")
                ],
                screenshots: ["3-statistics"]
            ),
            ScreenConfig(
                languages: [
                    LanguageConfig(locale: "en-GB", title: "Add records")
                ],
                screenshots: ["4-add-record"]
            ),
            ScreenConfig(
                languages: [
                    LanguageConfig(locale: "en-GB", title: "iCloud and more")
                ],
                screenshots: ["5-welcome-sheet"]
            ),
            ScreenConfig(
                languages: [
                    LanguageConfig(locale: "en-GB", title: "Settings")
                ],
                screenshots: ["6-settings"]
            )
        ]
    }
}

struct LanguageConfig: Decodable {
    let locale: String
    let title: String
}
