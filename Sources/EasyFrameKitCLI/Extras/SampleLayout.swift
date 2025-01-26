import SwiftUI
import FrameKit

struct SampleLayout: LayoutProvider {
    let size: CGSize
    let deviceFrameOffset: CGSize
    let textInsets: EdgeInsets
    let imageInsets: EdgeInsets
    let keywordFontSize: CGFloat
    let titleFontSize: CGFloat
    let textGap: CGFloat
    let textColor: Color
    let backgroundColor: Color
}
