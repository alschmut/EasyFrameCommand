//
//  CustomBackgroundView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 02.02.25.
//

import SwiftUI

struct CustomBackgroundView: View {
    let pageIndex: Int

    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.5, 0), .init(1, 0),
            .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1), .init(1, 1)
        ], colors: colors)
    }
    
    let orange = Color(red: 251 / 255, green: 133 / 255, blue: 0 / 255)
    let blue = Color(red: 30 / 255, green: 85 / 255, blue: 125 / 255)
    let purple = Color.purple

    var colors: [Color] {
        if pageIndex % 3 == 0 {
            return [
                purple, purple, blue,
                orange, orange, purple,
                orange, orange, orange
            ]
        } else if pageIndex % 3 == 1 {
            return [
                blue, purple, purple,
                purple, orange, blue,
                orange, orange, orange
            ]
        } else {
            return [
                purple, purple, purple,
                blue, orange, orange,
                orange, orange, orange
            ]
        }
    }
}

#Preview {
    CustomBackgroundView(pageIndex: 0)
}
