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

    @Argument(
        help: "An absolute or relative path to the parent folder, which contains the EasyFrame.json file and a raw-screeshots folder with individual locale folders",
        completion: .file()
    )
    var rootFolder: String

    @MainActor
    mutating func run() async throws {
        let rootFolderURL = URL(fileURLWithPath: rootFolder)
        let rawScreenshotsFolderURL = rootFolderURL.appendingPathComponent("raw-screenshots")
        let outputFolderURL = rootFolderURL.appendingPathComponent("screenshots")

        let easyFrameConfig = try getEasyFrameConfig(rawScreenshotsFolderURL: rawScreenshotsFolderURL)

        try easyFrameConfig.pages.enumerated().forEach { pageIndex, page in
            try page.languages.forEach { language in

                let screenshotsLocaleFolderURL = rawScreenshotsFolderURL.appendingPathComponent(language.locale)
                let outputFolderURL = outputFolderURL.appendingPathComponent(language.locale)

                switch page.type {
                case .default(let screenshot):
                    try createDefaultScreenshotPage(
                        pageIndex: pageIndex,
                        language: language,
                        screenshotsLocaleFolderURL: screenshotsLocaleFolderURL,
                        outputFolderURL: outputFolderURL,
                        screenshot: screenshot
                    )
                }
            }
        }
    }

    @MainActor
    private func createDefaultScreenshotPage(
        pageIndex: Int,
        language: LanguageConfig,
        screenshotsLocaleFolderURL: URL,
        outputFolderURL: URL,
        screenshot: String
    ) throws {
        try FileManager.default
            .contentsOfDirectory(at: screenshotsLocaleFolderURL, includingPropertiesForKeys: nil, options: [])
            .filter { url in
                url.lastPathComponent.contains(screenshot)
            }
            .forEach { screenshot in
                let screenshotImage = try getNSImage(fromPath: screenshot.relativePath)
                let layout = try getDeviceLayout(pixelSize: screenshotImage.pixelSize)
                let frameImage = try getFrameImage(from: layout)

                let frameViewModel = FrameViewModel(
                    screenshotImage: screenshotImage,
                    frameImage: frameImage,
                    frameScreenSize: layout.frameScreenSize,
                    screenshotCornerRadius: layout.cornerRadius,
                    frameOffset: layout.deviceFrameOffset
                )
                let deviceFrameView = DeviceFrameView(viewModel: frameViewModel)
                let framedScreenshot = try getNSImage(fromView: deviceFrameView, size: frameImage.size)

                let screenshotViewModel = ScreenshotViewModel(
                    pageIndex: pageIndex,
                    title: language.title,
                    description: language.description,
                    framedScreenshots: [framedScreenshot]
                )

                let screenshotView = ScreenshotView(
                    layout: layout,
                    viewModel: screenshotViewModel,
                    locale: language.locale
                )
                let nsImage = try getNSImage(fromView: screenshotView, size: layout.frameScreenSize)

                try FileManager.default.createDirectory(at: outputFolderURL, withIntermediateDirectories: true)
                let fileName = screenshot
                    .deletingPathExtension()
                    .appendingPathExtension("jpg")
                    .lastPathComponent
                let outputFileURL = outputFolderURL.appendingPathComponent(fileName)
                try saveFile(nsImage: nsImage, outputPath: outputFileURL.relativePath)
            }
    }

    private func getEasyFrameConfig(rawScreenshotsFolderURL: URL) throws -> EasyFrameConfig {
        let easyFrameJsonFileURL = rawScreenshotsFolderURL.appendingPathComponent("EasyFrame.json")
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

    private func getDeviceLayout(pixelSize: CGSize) throws -> Layout {
        guard let matchingDevice = SupportedDevice.allCases.first(where: { device in
            device.value.allScreenSizes.contains(pixelSize)
        }) else {
            throw EasyFrameError.deviceFrameNotSupported("No matching device frame found for pixelSize \(pixelSize)")
        }
        return matchingDevice.value
    }

    private func getFrameImage(from layout: Layout) throws -> NSImage {
        let url = Bundle.module.url(forResource: layout.frameImageName, withExtension: nil)!
        return NSImage(contentsOf: url)!
    }

    enum EasyFrameError: Error {
        case fileNotFound(String)
        case imageOperationFailure(String)
        case fileSavingFailure(String)
        case deviceFrameNotSupported(String)
    }
}
