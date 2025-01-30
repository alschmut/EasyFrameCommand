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
    let languages: [LanguageConfig]
    let type: PageType

    enum CodingKeys: CodingKey {
        case languages
        case screenshotsSingleHero
        case screenshotsDoubleHero
        case screenshot
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.languages = try container.decode([LanguageConfig].self, forKey: .languages)
        if let screenshotsSingleHero = try? container.decode([String].self, forKey: .screenshotsSingleHero) {
            self.type = .singleHero(screenshots: screenshotsSingleHero)
        } else if let screenshotsDoubleHero = try? container.decode([String].self, forKey: .screenshotsDoubleHero) {
            self.type = .doubleHero(screenshots: screenshotsDoubleHero)
        } else {
            guard let screenshot = try? container.decode(String.self, forKey: .screenshot) else {
                fatalError("Invalid configuration file")
            }
            self.type = .default(screenshot: screenshot)
        }
    }
}

struct LanguageConfig: Decodable {
    let locale: String
    let title: String
}

enum PageType: Decodable {
    case singleHero(screenshots: [String])
    case doubleHero(screenshots: [String])
    case `default`(screenshot: String)
}
