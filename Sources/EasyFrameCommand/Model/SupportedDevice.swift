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

    var value: Layout {
        switch self {
        case .iPhone15ProMax: .iPhone15ProMax
        case .iPadPro: .iPadPro
        }
    }

    var frameImageName: String {
        switch self {
        case .iPhone15ProMax: "Apple iPhone 14 Pro Max Black.png"
        case .iPadPro: "Apple iPhone 14 Pro Max Black.png" // TODO: Use correct device frame
        }
    }
}

