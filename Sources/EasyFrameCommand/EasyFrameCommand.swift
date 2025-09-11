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
        let layout = try getDeviceLayout(pixelSize: screenshotNSImage.pixelSize)
        let deviceNSImage = try FileHelper.getBundledNSImage(fromFileName: layout.deviceImageName)

        let framedScreenshotView = FramedScreenshotView(
            screenshotNSImage: screenshotNSImage,
            deviceNSImage: deviceNSImage,
            deviceScreenSize: layout.deviceScreenSize,
            clipCornerRadius: layout.clipCornerRadius,
            devicePositioningOffset: layout.devicePositioningOffset
        )
        let framedScreenshotNSImage = try FileHelper.getNSImage(
            fromView: framedScreenshotView,
            size: deviceNSImage.size
        )

        let screenshotDesignView = ScreenshotDesignView(
            layout: layout,
            locale: languageConfig.locale,
            pageIndex: pageIndex,
            title: languageConfig.title,
            description: languageConfig.description,
            framedScreenshotNSImage: framedScreenshotNSImage
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
    
    private func getDeviceLayout(pixelSize: CGSize) throws -> Layout {
        guard let layout = SupportedDevice.getFirstMatchingLayout(byPixelSize: pixelSize) else {
            throw EasyFrameError.deviceFrameNotSupported("No matching device frame found for pixelSize \(pixelSize)")
        }
        return layout
    }

    enum EasyFrameError: Error {
        case deviceFrameNotSupported(String)
    }
}
