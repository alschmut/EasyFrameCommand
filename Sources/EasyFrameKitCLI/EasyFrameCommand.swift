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
        help: "\(SampleLayoutOption.allCases.map({ "\"\($0.rawValue)\"" }).joined(separator: ", "))",
        completion: .list(SampleLayoutOption.allCases.map(\.rawValue))
    )
    var layout: SampleLayoutOption

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
        let framedScreenshots = try screenshots.compactMap { screenshot in
            let framedScreenshot = try makeImage(
                screenshot: screenshot,
                deviceFrame: deviceFrame,
                screenshotCornerRadius: layout.cornerRadius,
                deviceFrameOffset: layout.deviceFrameOffset
            )
            return Image(nsImage: framedScreenshot)
        }

        let backgroundImage: Image? = if let backgroundImage { Image(nsImage: try nsImage(fromPath: backgroundImage)) } else { nil }
        let content = SampleContent(
            title: title,
            backgroundImage: backgroundImage,
            framedScreenshots: framedScreenshots
        )

        let view = SampleStoreScreenshotView(layout: layout, content: content)
        let viewWithEnvironment = view
            .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
            .environment(\.locale, Locale(identifier: locale))
        let nsImage = try nsImage(fromView: viewWithEnvironment, size: view.layout.size)
        try saveFile(nsImage: nsImage, outputPath: output)
    }

    @MainActor
    private func makeImage(
        screenshot: String,
        deviceFrame: String,
        screenshotCornerRadius: CGFloat,
        deviceFrameOffset: CGSize
    ) throws -> NSImage {
        let screenshotImage = try nsImage(fromPath: screenshot)
        let deviceFrameImage = try nsImage(fromPath: deviceFrame)
        let view = DeviceFrameView(
            screenshotImage: ImageData(nsImage: screenshotImage, cornerRadius: screenshotCornerRadius),
            frameImage: ImageData(nsImage: deviceFrameImage, offset: deviceFrameOffset)
        )
        return try nsImage(fromView: view, size: deviceFrameImage.size)
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

    private func nsImage(fromPath path: String) throws -> NSImage {
        let absolutePath = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath).path
        guard let deviceFrameImage = NSImage(contentsOfFile: absolutePath) else {
            throw EasyFrameError.fileNotFound("device frame was not found at \(path)")
        }
        return deviceFrameImage
    }

    @MainActor
    private func nsImage<Content: View>(fromView view: Content, size: CGSize) throws -> NSImage {
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
