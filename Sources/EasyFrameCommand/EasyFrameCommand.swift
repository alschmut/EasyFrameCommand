//
//  EasyFrameCommand.swift
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
        let easyFrameJsonFileURL = rawScreenshotsFolderURL.appendingPathComponent("EasyFrame.json")
        let easyFrameConfig: EasyFrameConfig = try getFileContent(from: easyFrameJsonFileURL)

        for (pageIndex, page) in easyFrameConfig.pages.enumerated() {
            for languagesConfig in page.languagesConfig {
                let screenshotsLocaleFolderURL = rawScreenshotsFolderURL.appendingPathComponent(languagesConfig.locale)
                let outputFolderURL = outputFolderURL.appendingPathComponent(languagesConfig.locale)

                let matchingScreenshotURLs = try FileManager.default
                    .contentsOfDirectory(at: screenshotsLocaleFolderURL, includingPropertiesForKeys: nil, options: [])
                    .filter { $0.lastPathComponent.contains(page.screenshot) }
                
                for screenshotURL in matchingScreenshotURLs {
                    try createAndSaveScreenshotDesignView(
                        pageIndex: pageIndex,
                        languageConfig: languagesConfig,
                        outputFolderURL: outputFolderURL,
                        screenshotURL: screenshotURL
                    )
                }
            }
        }
    }

    @MainActor
    private func createAndSaveScreenshotDesignView(
        pageIndex: Int,
        languageConfig: LanguageConfig,
        outputFolderURL: URL,
        screenshotURL: URL
    ) throws {
        let screenshotNSImage = try getNSImage(fromDiskPath: screenshotURL.relativePath)
        let layout = try getDeviceLayout(pixelSize: screenshotNSImage.pixelSize)
        let deviceNSImage = try getBundledNSImage(fromFileName: layout.deviceImageName)

        let deviceFrameView = FramedScreenshotView(
            screenshotNSImage: screenshotNSImage,
            deviceNSImage: deviceNSImage,
            deviceScreenSize: layout.deviceScreenSize,
            clipCornerRadius: layout.clipCornerRadius,
            devicePositioningOffset: layout.devicePositioningOffset
        )
        let framedScreenshot = try getNSImage(fromView: deviceFrameView, size: deviceNSImage.size)

        let screenshotDesignView = ScreenshotDesignView(
            layout: layout,
            locale: languageConfig.locale,
            pageIndex: pageIndex,
            title: languageConfig.title,
            description: languageConfig.description,
            framedScreenshot: framedScreenshot
        )
        let screenshotDesignViewNSImage = try getNSImage(fromView: screenshotDesignView, size: layout.deviceScreenSize)

        try FileManager.default.createDirectory(at: outputFolderURL, withIntermediateDirectories: true)
        let outputFileName = screenshotURL
            .deletingPathExtension()
            .appendingPathExtension("jpg")
            .lastPathComponent
        let outputFileURL = outputFolderURL.appendingPathComponent(outputFileName)
        try saveFile(nsImage: screenshotDesignViewNSImage, outputPath: outputFileURL.relativePath)
    }
    
    private func getDeviceLayout(pixelSize: CGSize) throws -> Layout {
        guard let layout = SupportedDevice.getFirstMatchingLayout(byPixelSize: pixelSize) else {
            throw EasyFrameError.deviceFrameNotSupported("No matching device frame found for pixelSize \(pixelSize)")
        }
        return layout
    }

    private func getFileContent<T: Decodable>(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
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

    private func getNSImage(fromDiskPath path: String) throws -> NSImage {
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

    private func getBundledNSImage(fromFileName fileName: String) throws -> NSImage {
        let url = Bundle.module.url(forResource: fileName, withExtension: nil)!
        return NSImage(contentsOf: url)!
    }

    enum EasyFrameError: Error {
        case fileNotFound(String)
        case imageOperationFailure(String)
        case fileSavingFailure(String)
        case deviceFrameNotSupported(String)
    }
}
