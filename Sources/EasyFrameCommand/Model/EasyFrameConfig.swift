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
        if let screenshot = try? container.decode(String.self, forKey: .screenshot) {
            self.type = .default(screenshot: screenshot)
        } else {
            throw PageConfigError.invalidConfiguration
        }
    }

    enum PageConfigError: Error {
        case invalidConfiguration
    }
}

struct LanguageConfig: Decodable {
    let locale: String
    let title: String
    let description: String
}

enum PageType: Decodable {
    case `default`(screenshot: String)
}
