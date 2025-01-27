//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import ArgumentParser

enum SampleLayoutOption: String, CaseIterable, ExpressibleByArgument {
    case iPhone15ProMax = "iPhone_15_pro"
    case iPadPro = "ipad_pro"

    init?(argument: String) {
        self.init(rawValue: argument)
    }

    var value: SampleLayout {
        switch self {
        case .iPhone15ProMax: return .iPhone15ProMax
        case .iPadPro: return .iPadPro
        }
    }
}

