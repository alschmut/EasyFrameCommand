//
//  DeviceFrameView.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI
import ArgumentParser

@main
struct EasyFrameCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "easy-frame")
    }

    @Option(
        name: [.customShort("L"), .customLong("layout")],
        help: "\(LayoutOption.allCases.map({ "\"\($0.rawValue)\"" }).joined(separator: ", "))",
        completion: .list(LayoutOption.allCases.map(\.rawValue))
    )
    var layout: LayoutOption

    @Option(name: .shortAndLong, help: "A target locale's identifier to be used to adjust layout within view")
    var locale: String

    @Option(name: .shortAndLong, help: "A title to be shown with bold font")
    var title: String

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

    @Flag(name: .long, help: "If the language is read right-to-left")
    var isRightToLeft: Bool = false

    @Option(
        name: .shortAndLong,
        parsing: .remaining,
        help: "An absolute or relative path to the image to be shown as the embeded screenshot within a device frame",
        completion: .file()
    )
    var screenshots: [String] = []

    @MainActor
    mutating func run() async throws {
        let layout = layout.value
        let frameImage = try getNSImage(fromPath: deviceFrame)

        let framedScreenshots = try screenshots.map { screenshot in
            let screenshotImage = try getNSImage(fromPath: screenshot)
            let frameData = FrameData(
                screenshotImage: screenshotImage,
                frameImage: frameImage,
                screenshotCornerRadius: layout.cornerRadius,
                frameOffset: layout.deviceFrameOffset
            )
            let view = DeviceFrameView(frameData: frameData)
            return try getNSImage(fromView: view, size: frameImage.size)
        }

        let content = ViewModel(
            title: title,
            backgroundImage: try backgroundImage.map { try getNSImage(fromPath: $0) },
            framedScreenshots: framedScreenshots
        )

        let view = ScreenshotView(
            layout: layout,
            content: content,
            isRightToLeft: isRightToLeft,
            locale: locale
        )
        let nsImage = try getNSImage(fromView: view, size: view.layout.size)
        try saveFile(nsImage: nsImage, outputPath: output)
    }

    private func saveFile(nsImage: NSImage, outputPath: String) throws {
        guard let jpegData = jpegDataFrom(image: nsImage) else {
            throw EasyFrameError.imageOperationFailure("Error: can't generate image from view")
        }

        let result = FileManager.default.createFile(atPath: outputPath, contents: jpegData, attributes: nil)
        guard result else {
            throw EasyFrameError.fileSavingFailure("Error: can't save generated image at \(outputPath)")
        }
    }

    private func jpegDataFrom(image: NSImage) -> Data? {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [:])
    }

    private func getNSImage(fromPath path: String) throws -> NSImage {
        let absolutePath = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath).path
        guard let deviceFrameImage = NSImage(contentsOfFile: absolutePath) else {
            throw EasyFrameError.fileNotFound("device frame was not found at \(path)")
        }
        return deviceFrameImage
    }

    @MainActor
    private func getNSImage<Content: View>(fromView view: Content, size: CGSize) throws -> NSImage {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(size)
        renderer.scale = 1.0
        guard let nsImage = renderer.nsImage else {
            throw EasyFrameError.imageOperationFailure("Error: can't generate image from view")
        }
        return nsImage
    }
}

enum EasyFrameError: Error {
    case fileNotFound(String)
    case imageOperationFailure(String)
    case fileSavingFailure(String)
}

struct FrameData {
    let screenshotImage: Image
    let screenshotSize: CGSize
    let screenshotCornerRadius: CGFloat

    let frameImage: Image
    let frameSize: CGSize
    let frameOffset: CGSize

    init(
        screenshotImage: NSImage,
        frameImage: NSImage,
        screenshotCornerRadius: CGFloat,
        frameOffset: CGSize
    ) {
        self.screenshotImage = Image(nsImage: screenshotImage)
        self.screenshotSize = Self.size(fromNSImage: screenshotImage)
        self.screenshotCornerRadius = screenshotCornerRadius

        self.frameImage = Image(nsImage: frameImage)
        self.frameSize = Self.size(fromNSImage: frameImage)
        self.frameOffset = frameOffset
    }

    private static func size(fromNSImage nsImage: NSImage) -> CGSize {
        let representation = nsImage.representations[0]
        return CGSize(width: representation.pixelsWide, height: representation.pixelsHigh)
    }
}
