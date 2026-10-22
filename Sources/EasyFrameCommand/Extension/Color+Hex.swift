//
//  Color+Hex.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 22.10.26.
//

import SwiftUI

extension Color {

    /// Supports `#RGB`, `#RGBA`, `#RRGGBB` and `#RRGGBBAA`
    init?(hex: String) {
        var hex = String(hex.trimmingPrefix("#"))
        if hex.count == 3 || hex.count == 4 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        if hex.count == 6 {
            hex += "FF"
        }
        guard hex.count == 8, let value = UInt64(hex, radix: 16) else {
            return nil
        }
        self.init(
            .sRGB,
            red: Double((value >> 24) & 0xFF) / 255,
            green: Double((value >> 16) & 0xFF) / 255,
            blue: Double((value >> 8) & 0xFF) / 255,
            opacity: Double(value & 0xFF) / 255
        )
    }
}
