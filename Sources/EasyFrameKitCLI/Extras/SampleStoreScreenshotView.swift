import AppKit
import FrameKit
import SwiftUI

struct SampleStoreScreenshotView: StoreScreenshotView {
    let layout: SampleLayout
    let content: SampleContent

    static func makeView(layout: SampleLayout, content: SampleContent) -> Self {
        Self(layout: layout, content: content)
    }

    var body: some View {
        ZStack {
            layout.backgroundColor

            if let backgroundImage = content.backgroundImage {
                Image(nsImage: backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }

            Image(nsImage: content.framedScreenshots[0])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(layout.imageInsets)

            VStack(alignment: .leading, spacing: layout.textGap) {
                Text(content.keyword)
                    .font(keywordFont)
                    .foregroundColor(layout.textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)

                if let title = content.title {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(layout.textColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(self.layout.textInsets)
        }
    }
}

//struct ImageView: View {
//    let screenshot: String
//    var body: some View {
//
//    }
//}
