import AppKit
import FrameKit
import SwiftUI


struct SampleHeroStoreScreenshotView: StoreScreenshotView {
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

            GeometryReader() { geometry in
                ZStack {
                    HStack(alignment: .center, spacing: 10) {
                        Image(nsImage: content.framedScreenshots[1])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width / 2.6)

                        Spacer()

                        Image(nsImage: content.framedScreenshots[2])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width / 2.6)
                    }

                    Image(nsImage: content.framedScreenshots[0])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width / 2.2, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(self.layout.imageInsets)
            }

            Text(content.keyword)
                .font(keywordFont)
                .foregroundColor(self.layout.textColor)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(self.layout.textInsets)
        }
    }
}
