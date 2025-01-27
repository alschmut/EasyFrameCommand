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

    @Option(
        name: .shortAndLong,
        help: "An absolute or relative path to the image to be shown as background",
        completion: .file()
    )
    var backgroundImage: String?

    @Option(
        name: .shortAndLong,
        help: "An absolute or relative path to the root folder, which contains the individual folder for the locales and the EasyFrame.json file",
        completion: .file()
    )
    var rootFolder: String

    @Option(
        name: .shortAndLong,
        help: "An absolute or relative path to the image to be shown as the device frame. Download them by 'fastlane frameit download_frames')",
        completion: .file()
    )
    var deviceFrame: String

    @Flag(name: .long, help: "If the language is read right-to-left")
    var isRightToLeft: Bool = false

    @MainActor
    mutating func run() async throws {
        let layout = layout.value
        let frameImage = try getNSImage(fromPath: deviceFrame)

        let rootFolderURL = URL(fileURLWithPath: rootFolder)
        let screenshotsFolderURL = rootFolderURL.appendingPathComponent("screenshots")
        let outputFolderURL = rootFolderURL.appendingPathComponent("framed_screenshots")
        let easyFrameJsonFileURL = screenshotsFolderURL.appendingPathComponent("EasyFrame.json")

        let data = try Data(contentsOf: easyFrameJsonFileURL)
        let easyFrameConfig = try JSONDecoder().decode(EasyFrameConfig.self, from: data)

        try easyFrameConfig.screens.forEach { screen in
            try screen.languages.forEach { language in

                let screenshotsLocaleFolderURL = screenshotsFolderURL.appendingPathComponent(language.locale)
                let outputFolderURL = outputFolderURL.appendingPathComponent(language.locale)

                try screen.screenshots.forEach { screenshot in
                    let matchingScreenshots = try FileManager.default
                        .contentsOfDirectory(at: screenshotsLocaleFolderURL, includingPropertiesForKeys: nil, options: [])
                        .filter { url in
                            url.lastPathComponent.contains(screenshot)
                        }

                    let framedScreenshots = try matchingScreenshots.map { screenshot in
                        let screenshotImage = try getNSImage(fromPath: screenshot.relativePath)
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
                        title: language.title,
                        backgroundImage: try backgroundImage.map { try getNSImage(fromPath: $0) },
                        framedScreenshots: framedScreenshots
                    )

                    let view = ScreenshotView(
                        layout: layout,
                        content: content,
                        isRightToLeft: isRightToLeft,
                        locale: language.locale
                    )
                    let nsImage = try getNSImage(fromView: view, size: view.layout.size)

                    try FileManager.default.createDirectory(at: outputFolderURL, withIntermediateDirectories: true)
                    let ouputFileURL = outputFolderURL.appendingPathComponent(screenshot).appendingPathExtension("jpg")
                    try saveFile(nsImage: nsImage, outputPath: ouputFileURL.relativePath)
                }
            }
        }
    }

    private func saveFile(nsImage: NSImage, outputPath: String) throws {
        guard let jpegData = jpegDataFrom(image: nsImage) else {
            throw EasyFrameError.imageOperationFailure("Error: can't generate image from view")
        }

        let result = FileManager.default.createFile(atPath: outputPath, contents: jpegData)
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
