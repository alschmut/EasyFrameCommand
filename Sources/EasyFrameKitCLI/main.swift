import AppKit
import SwiftUI
import FrameKit
import ArgumentParser

EasyFrameCommand.main()

struct EasyFrameCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "easy-frame")
    }

    @Option(name: [.customShort("L"), .customLong("layout")],
            help: "\(SampleLayoutOption.allCases.map({ "\"\($0.rawValue)\"" }).joined(separator: ", "))",
            completion: .list(SampleLayoutOption.allCases.map(\.rawValue)))
    var layout: SampleLayoutOption

    @Option(name: .shortAndLong, help: "A target locale's identifier to be used to adjust layout within view")
    var locale: String

    @Option(name: .shortAndLong, help: "A string to be shown with bold font")
    var keyword: String

    @Option(name: .shortAndLong, help: "A string to be shown with regular font")
    var title: String

    @Option(name: .shortAndLong,
            help: "An absolute or relative path to the image to be shown as background",
            completion: .file())
    var backgroundImage: String?


    @Option(name: .shortAndLong,
            help: "An absolute or relative path to the image to be shown as the device frame. Download them by 'fastlane frameit download_frames')",
            completion: .file())
    var deviceFrame: String

    @Option(name: .shortAndLong, help: "An absolute or relative path to output", completion: .file())
    var output: String

    @Flag(name: .long,
          help: "To choose hero screenshot view pass this flag.")
    var isHero: Bool = false

    @Flag(name: .long, help: "If tehe target is RLT language, then add this")
    var isRTL: Bool = false

    @Option(name: .shortAndLong,
            help: "An absolute or relative path to the image to be shown as the embeded screenshot within a device frame",
            completion: .file())
    var screenshots: [String] = []

    mutating func run() throws {
        let layoutDirection: LayoutDirection = isRTL ? .rightToLeft : .leftToRight
        let layout = layout.value

        // Device frame's image needs to be generted separaratedly to make framing logic easy
        let framedScreenshots = try screenshots.compactMap({ screenshot in
            try DeviceFrame.makeImage(
                screenshot: absolutePath(screenshot),
                deviceFrame: absolutePath(deviceFrame),
                deviceFrameOffset: layout.deviceFrameOffset
            )
        })

        let content = SampleContent(
            locale: Locale(identifier: locale),
            keyword: keyword,
            title: title,
            backgroundImage: backgroundImage.flatMap({ NSImage(contentsOfFile: absolutePath($0)) }),
            framedScreenshots: framedScreenshots
        )

        let render = StoreScreenshotRenderer(outputPath: output, layoutDirection: layoutDirection)
        if isHero {
            try render(SampleHeroStoreScreenshotView.makeView(layout: layout, content: content))
        } else {
            try render(SampleStoreScreenshotView.makeView(layout: layout, content: content))
        }
    }
}

//@MainActor
//func run(screenshot: String, deviceFrame: String) throws {
//    // Define layout for your desired device (this could be defined somewhere as static property)
//    // This is what you need to define by yourself
//    let layoutForiPhone65inch = SampleLayout(
//        size: CGSize(width: 1242, height: 2688),
//        deviceFrameOffset: .zero,
//        textInsets: EdgeInsets(top: 72, leading: 120, bottom: 0, trailing: 120),
//        imageInsets: EdgeInsets(top: 0, leading: 128, bottom: 72, trailing: 128),
//        keywordFontSize: 148,
//        titleFontSize: 72,
//        textGap: 24,
//        textColor: .white,
//        backgroundColor: Color(red: 255 / 255, green: 153 / 255, blue: 51 / 255)
//    )
//
//    // DeviceFrame.makeImage is to embed "app" screenshot into given device frame
//    let framedScreenshot = try DeviceFrame.makeImage(
//        screenshot: absolutePath(screenshot),
//        deviceFrame: absolutePath(deviceFrame),
//        deviceFrameOffset: layoutForiPhone65inch.deviceFrameOffset
//    )
//
//    let framedScreenshots: [NSImage] = if let framedScreenshot { [framedScreenshot] } else { [] }
//
//    // Arbitary struct to include contents to be rendered on store screenshtos
//    // This is what you need to define
//    let content = SampleContent(
//        locale: .current,
//        keyword: "Weather",
//        title: "Come to the UK",
//        framedScreenshots: framedScreenshots
//    )
//
//    // Ininitialize the designed view that you defined
//    let view = SampleStoreScreenshotView.makeView(layout: layoutForiPhone65inch, content: content)
//
//    // Render the image into outputPath with this
//    let render = StoreScreenshotRenderer(outputPath: "./output.jpg", layoutDirection: .leftToRight)
//    try render(view)
//}
