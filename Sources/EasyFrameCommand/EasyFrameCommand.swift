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

    @MainActor
    mutating func run() async throws {
        let rootFolderURL = URL(fileURLWithPath: rootFolder)
        let screenshotsFolderURL = rootFolderURL.appendingPathComponent("screenshots")
        let outputFolderURL = rootFolderURL.appendingPathComponent("framed_screenshots")

        let easyFrameConfig = try getEasyFrameConfig(screenshotsFolderURL: screenshotsFolderURL)

        try easyFrameConfig.appStoreScreens.forEach { appStoreScreen in
            try appStoreScreen.languages.forEach { language in

                let screenshotsLocaleFolderURL = screenshotsFolderURL.appendingPathComponent(language.locale)
                let outputFolderURL = outputFolderURL.appendingPathComponent(language.locale)

                try appStoreScreen.screenshots.forEach { screenshot in
                    let layout = Layout.iPhone15ProMax
                    let matchingScreenshots = try FileManager.default
                        .contentsOfDirectory(at: screenshotsLocaleFolderURL, includingPropertiesForKeys: nil, options: [])
                        .filter { url in
                            url.lastPathComponent.contains(screenshot)
                        }

                    let framedScreenshots = try matchingScreenshots.map { screenshot in
                        let screenshotImage = try getNSImage(fromPath: screenshot.relativePath)
                        let frameImage = try getFrameImage(pixelSize: screenshotImage.pixelSize)

                        let frameData = FrameData(
                            screenshotImage: screenshotImage,
                            frameImage: frameImage,
                            screenshotCornerRadius: layout.cornerRadius,
                            frameOffset: layout.deviceFrameOffset
                        )
                        let view = DeviceFrameView(frameData: frameData)
                        return try getNSImage(fromView: view, size: frameImage.size)
                    }

                    let viewModel = ViewModel(
                        title: language.title,
                        backgroundImage: try backgroundImage.map { try getNSImage(fromPath: $0) },
                        framedScreenshots: framedScreenshots
                    )

                    let view = ScreenshotView(
                        layout: layout,
                        content: viewModel,
                        locale: language.locale
                    )
                    let nsImage = try getNSImage(fromView: view, size: view.layout.size)

                    try FileManager.default.createDirectory(at: outputFolderURL, withIntermediateDirectories: true)
                    let fileName = matchingScreenshots.first!
                        .deletingPathExtension()
                        .appendingPathExtension("jpg")
                        .lastPathComponent
                    let ouputFileURL = outputFolderURL.appendingPathComponent(fileName)
                    try saveFile(nsImage: nsImage, outputPath: ouputFileURL.relativePath)
                }
            }
        }
    }

    private func getEasyFrameConfig(screenshotsFolderURL: URL) throws -> EasyFrameConfig {
        let easyFrameJsonFileURL = screenshotsFolderURL.appendingPathComponent("EasyFrame.json")
        let data = try Data(contentsOf: easyFrameJsonFileURL)
        return try JSONDecoder().decode(EasyFrameConfig.self, from: data)
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

    func getFrameImage(pixelSize: CGSize) throws -> NSImage {
        guard let matchingDevice = LayoutOption.allCases.first(where: { layoutOption in
            layoutOption.value.size == pixelSize
        }) else {
            throw EasyFrameError.deviceFrameNotSupported("No matching device frame found for pixelSize \(pixelSize)")
        }
        // NSImage(resource: .appleiPhone14ProMaxBlack)
        let url = URL(string: "file:///Users/alexander.schmutz/.fastlane/frameit/latest/\(matchingDevice.frameImageName)")!
        return NSImage(contentsOf: url)!
    }

    enum EasyFrameError: Error {
        case fileNotFound(String)
        case imageOperationFailure(String)
        case fileSavingFailure(String)
        case deviceFrameNotSupported(String)
    }
}
