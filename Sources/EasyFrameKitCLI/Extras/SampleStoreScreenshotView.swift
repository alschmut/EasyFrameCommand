import AppKit
import FrameKit
import SwiftUI

struct SampleStoreScreenshotView: StoreScreenshotView {
    let layout: SampleLayout
    let content: SampleContent

    var body: some View {
        ZStack {
            layout.backgroundColor

            if let backgroundImage = content.backgroundImage {
                backgroundImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }

            content.framedScreenshots[0]
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(layout.imageInsets)

            VStack(alignment: .leading, spacing: layout.textGap) {
                Text(content.title)
                    .font(keywordFont)
                    .foregroundColor(layout.textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(layout.textInsets)
        }
    }
}
