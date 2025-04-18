//
//  SupportedDevice.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import Foundation

enum SupportedDevice: CaseIterable {
    case iPhone15ProMax
    case iPadPro
    case iPhoneSE3rdGen

    var value: Layout {
        switch self {
        case .iPhone15ProMax: .iPhone15ProMax
        case .iPadPro: .iPadPro
        case .iPhoneSE3rdGen: .iPhoneSE3rdGen
        }
    }
}

