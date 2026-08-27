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
        let easyFrameConfig: EasyFrameConfig = try FileHelper.getFileContent(from: easyFrameJsonFileURL)

        for (pageIndex, page) in easyFrameConfig.pages.enumerated() {
            for languagesConfig in page.languagesConfig {
                let screenshotsLocaleFolderURL = rawScreenshotsFolderURL.appendingPathComponent(languagesConfig.locale)
                let outputFolderURL = outputFolderURL.appendingPathComponent(languagesConfig.locale)

                let matchingScreenshotURLs = try FileManager.default
                    .contentsOfDirectory(at: screenshotsLocaleFolderURL, includingPropertiesForKeys: nil, options: [])
                    .filter { $0.lastPathComponent.contains(page.screenshotSuffix) }
                
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
        let screenshotNSImage = try FileHelper.getNSImage(fromDiskPath: screenshotURL.relativePath)
        let outputName = screenshotURL.deletingPathExtension().lastPathComponent
        // The **device segment** only — everything before the first `-` — so a page suffix that
        // happens to read like a device name cannot select a layout.
        let deviceName = outputName.components(separatedBy: "-").first ?? ""
        let layout = try getDeviceLayout(deviceName: deviceName, pixelSize: screenshotNSImage.pixelSize)

        // Taken after the layout is chosen and before anything is composited: the canvas is the
        // layout's store slot, and the crop decides what fills it rather than how big it is.
        let capturedNSImage = layout.captureCrop.map { screenshotNSImage.cropped(to: $0) }
            ?? screenshotNSImage

        let framedScreenshotNSImage: NSImage
        if let deviceImageName = layout.deviceImageName {
            let deviceNSImage = try FileHelper.getBundledNSImage(fromFileName: deviceImageName)
            let framedScreenshotView = FramedScreenshotView(
                screenshotNSImage: capturedNSImage,
                deviceNSImage: deviceNSImage,
                deviceScreenSize: layout.deviceScreenSize,
                clipCornerRadius: layout.clipCornerRadius,
                devicePositioningOffset: layout.devicePositioningOffset,
                screenFrame: layout.screenFrame
            )
            framedScreenshotNSImage = try FileHelper.getNSImage(
                fromView: framedScreenshotView,
                // `pixelSize`, not `size`: `NSImage.size` is in points, derived from the file's DPI,
                // and `FramedScreenshotView` lays the bezel out at its pixel size. The two agree only
                // for 72 dpi art.
                size: deviceNSImage.pixelSize
            )
        } else {
            // Frameless. There is no bezel to composite, so the capture goes straight to the page,
            // which renders it as a card.
            framedScreenshotNSImage = capturedNSImage
        }

        let screenshotDesignView = ScreenshotDesignView(
            layout: layout,
            locale: languageConfig.locale,
            pageIndex: pageIndex,
            title: languageConfig.title,
            description: languageConfig.description,
            framedScreenshotNSImage: framedScreenshotNSImage,
            rendersAsCard: layout.isFrameless
        )
        let screenshotDesignViewNSImage = try FileHelper.getNSImage(
            fromView: screenshotDesignView,
            size: layout.deviceScreenSize
        )

        try FileManager.default.createDirectory(at: outputFolderURL, withIntermediateDirectories: true)
        let outputFileName = screenshotURL
            .deletingPathExtension()
            .appendingPathExtension("jpg")
            .lastPathComponent
        let outputFileURL = outputFolderURL.appendingPathComponent(outputFileName)
        try FileHelper.saveFile(
            nsImage: screenshotDesignViewNSImage,
            outputPath: outputFileURL.relativePath
        )
    }
    
    /// The frame for a capture: by device name if the name says which one, otherwise by pixel size.
    ///
    /// The name has to be tried first, because some devices cannot be told apart by size at all —
    /// Apple TV and Vision Pro both capture at exactly 3840 x 2160. Only a layout that declares
    /// `deviceNameMatches` is reachable that way, so a capture named the way `fastlane snapshot`
    /// names one goes on resolving by size exactly as before.
    private func getDeviceLayout(deviceName: String, pixelSize: CGSize) throws -> Layout {
        if let layout = SupportedDevice.layout(forDeviceName: deviceName) {
            return layout
        }
        guard let layout = SupportedDevice.getFirstMatchingLayout(byPixelSize: pixelSize) else {
            throw EasyFrameError.deviceFrameNotSupported(
                "No matching device frame found for '\(deviceName)' at pixelSize \(pixelSize)"
            )
        }
        return layout
    }

    enum EasyFrameError: Error {
        case deviceFrameNotSupported(String)
    }
}
