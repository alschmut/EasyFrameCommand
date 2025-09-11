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
    let type: PageType

    enum CodingKeys: String, CodingKey {
        case languages = "languages"
        case screenshot = "screenshot"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.languagesConfig = try container.decode([LanguageConfig].self, forKey: .languages)
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
