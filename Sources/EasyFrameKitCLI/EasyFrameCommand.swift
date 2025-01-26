import AppKit
import SwiftUI
import ArgumentParser

@main
struct EasyFrameCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "easy-frame")
    }

    @Option(
        name: [.customShort("L"), .customLong("layout")],
        help: "\(SampleLayoutOption.allCases.map({ "\"\($0.rawValue)\"" }).joined(separator: ", "))",
        completion: .list(SampleLayoutOption.allCases.map(\.rawValue))
    )
    var layout: SampleLayoutOption

    @Option(name: .shortAndLong, help: "A target locale's identifier to be used to adjust layout within view")
    var locale: String

    @Option(name: .shortAndLong, help: "A string to be shown with bold font")
    var keyword: String

    @Option(name: .shortAndLong, help: "A string to be shown with regular font")
    var title: String?

    @Option(
        name: .shortAndLong,
        help: "An absolute or relative path to the image to be shown as background",
        completion: .file()
    )
    var backgroundImage: String?


    @Option(
        name: .shortAndLong,
        help: "An absolute or relative path to the image to be shown as the device frame. Download them by 'fastlane frameit download_frames')",
        completion: .file()
    )
    var deviceFrame: String

    @Option(name: .shortAndLong, help: "An absolute or relative path to output", completion: .file())
    var output: String

    @Flag(name: .long, help: "To choose hero screenshot view pass this flag.")
    var isHero: Bool = false

    @Flag(name: .long, help: "If tehe target is RLT language, then add this")
    var isRTL: Bool = false

    @Option(
        name: .shortAndLong,
        parsing: .remaining,
        help: "An absolute or relative path to the image to be shown as the embeded screenshot within a device frame",
        completion: .file()
    )
    var screenshots: [String] = []

    mutating func run() async throws {
        let layout = layout.value

        var framedScreenshots: [NSImage] = []
        for screenshot in screenshots {
            let image = try await DeviceFrame.makeImage(
                screenshot: absolutePath(screenshot),
                deviceFrame: absolutePath(deviceFrame),
                deviceFrameOffset: layout.deviceFrameOffset
            )
            if let image {
                framedScreenshots.append(image)
            }
        }

        let content = SampleContent(
            locale: Locale(identifier: locale),
            keyword: keyword,
            title: title,
            backgroundImage: backgroundImage.flatMap({ NSImage(contentsOfFile: absolutePath($0)) }),
            framedScreenshots: framedScreenshots
        )

        let renderer = StoreScreenshotRenderer(
            outputPath: output,
            layoutDirection: isRTL ? .rightToLeft : .leftToRight
        )
        if isHero {
            try await renderer(SampleHeroStoreScreenshotView.makeView(layout: layout, content: content))
        } else {
            try await renderer(SampleStoreScreenshotView.makeView(layout: layout, content: content))
        }
    }
}

struct DeviceFrame {
    enum Error: Swift.Error {
        case fileNotFound(String)
    }

    static func makeImage(screenshot: String, deviceFrame: String, deviceFrameOffset: CGSize) async throws -> NSImage? {
        guard let screenshotImage = NSImage(contentsOfFile: absolutePath(screenshot)) else {
            throw Error.fileNotFound("screenshot was not found at \(screenshot)")
        }

        guard let deviceFrameImage = NSImage(contentsOfFile: absolutePath(deviceFrame)) else {
            throw Error.fileNotFound("device frame was not found at \(deviceFrame)")
        }

        return await makeDeviceFrameImage(
            screenshot: screenshotImage,
            deviceFrame: deviceFrameImage,
            deviceFrameOffset: deviceFrameOffset
        )
    }

    @MainActor
    private static func makeDeviceFrameImage(screenshot: NSImage, deviceFrame: NSImage, deviceFrameOffset: CGSize) -> NSImage? {
        let deviceFrameView = DeviceFrameView(
            deviceFrame: deviceFrame,
            screenshot: screenshot,
            offset: deviceFrameOffset
        )
        var renderer = ImageRenderer(content: deviceFrameView)
        renderer.proposedSize = .init(deviceFrame.size)
        renderer.scale = 1.0
        return renderer.nsImage
    }
}

struct DeviceFrameView: View {
    let deviceFrame: NSImage
    let screenshot: NSImage
    let offset: CGSize

    var body: some View {
        ZStack {
            Image(nsImage: screenshot)
                .resizable()
                .frame(width: screenshot.size.width, height: screenshot.size.height)
                .offset(offset)

            Image(nsImage: deviceFrame)
                .resizable()
                .frame(width: deviceFrame.size.width, height: deviceFrame.size.height)
        }
    }
}

func absolutePath(_ relativePath: String) -> String {
    URL(fileURLWithPath: NSString(string: relativePath).expandingTildeInPath).path
}

struct StoreScreenshotRenderer {
    let outputPath: String
    let layoutDirection: LayoutDirection

    enum Error: Swift.Error {
        case imageOperationFailure(String)
        case fileSavingFailure(String)
    }

    @MainActor
    func callAsFunction<View: StoreScreenshotView>(_ storeScreenshotView: View) throws {
        var renderer = ImageRenderer(content: storeScreenshotView)
        renderer.proposedSize = .init(storeScreenshotView.layout.size)
        renderer.scale = 1.0

        guard let nsImage = renderer.nsImage, let jpegData = jpegDataFrom(image: nsImage) else {
            throw Error.imageOperationFailure("Error: can't generate image from view")
        }

        let result = FileManager.default.createFile(atPath: outputPath, contents: jpegData, attributes: nil)
        guard result else {
            throw Error.fileSavingFailure("Error: can't save generated image at \(String(describing: outputPath))")
        }
    }

    func jpegDataFrom(image: NSImage) -> Data? {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [:])
    }
}




protocol LayoutProvider {
    var size: CGSize { get }
    var deviceFrameOffset: CGSize { get }
}

protocol StoreScreenshotView: View {
    associatedtype Layout: LayoutProvider
    associatedtype Content

    var layout: Layout { get }
    var content: Content { get }
    static func makeView(layout: Layout, content: Content) -> Self
}

protocol LayoutProviderOption: CaseIterable, RawRepresentable where RawValue == String {
    associatedtype Layout: LayoutProvider
    var value: Layout { get }
}
