//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import ArgumentParser

enum LayoutOption: String, CaseIterable, ExpressibleByArgument {
    case iPhone15ProMax = "iPhone_15_pro"
    case iPadPro = "ipad_pro"

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

