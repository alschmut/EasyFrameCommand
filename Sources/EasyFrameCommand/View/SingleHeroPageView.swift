//
//  SingleHeroPageView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct SingleHeroPageView: View {
    let viewModel: FrameViewModel

    var body: some View {
        ZStack {
            viewModel.screenshotImage
                .resizable()
                .frame(width: viewModel.screenshotSize.width, height: viewModel.screenshotSize.height)
                .clipShape(RoundedRectangle(cornerRadius: viewModel.screenshotCornerRadius))

            viewModel.frameImage
                .resizable()
                .frame(width: viewModel.frameSize.width, height: viewModel.frameSize.height)
                .offset(viewModel.frameOffset)
        }
    }
}
