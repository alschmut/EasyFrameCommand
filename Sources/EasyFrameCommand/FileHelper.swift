//
//  File.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 11.09.25.
//

import SwiftUI

struct FileHelper {
    
    static func getFileContent<T: Decodable>(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    static func saveFile(nsImage: NSImage, outputPath: String) throws {
        guard let jpegData = jpegDataFrom(image: nsImage) else {
            throw EasyFrameError.imageOperationFailure("Error: can't generate image from view")
        }

        let result = FileManager.default.createFile(atPath: outputPath, contents: jpegData)
        guard result else {
            throw EasyFrameError.fileSavingFailure("Error: can't save generated image at \(outputPath)")
        }
    }

    private static func jpegDataFrom(image: NSImage) -> Data? {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [:])
    }

    static func getNSImage(fromDiskPath path: String) throws -> NSImage {
        let absolutePath = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath).path
        guard let deviceFrameImage = NSImage(contentsOfFile: absolutePath) else {
            throw EasyFrameError.fileNotFound("device frame was not found at \(path)")
        }
        return deviceFrameImage
    }

    @MainActor
    static func getNSImage<Content: View>(fromView view: Content, size: CGSize) throws -> NSImage {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(size)
        renderer.scale = 1.0
        guard let nsImage = renderer.nsImage else {
            throw EasyFrameError.imageOperationFailure("Error: can't generate image from view")
        }
        return nsImage
    }

    /// The URL of a bundled bezel render, or `nil`.
    ///
    /// Split out of `getBundledNSImage` so a layout's art can be *checked* without loading it —
    /// see `LayoutTests.bundledArtResolves`.
    static func bundledURL(forFileName fileName: String) -> URL? {
        Bundle.module.url(forResource: fileName, withExtension: nil)
    }

    static func getBundledNSImage(fromFileName fileName: String) throws -> NSImage {
        // Both of these were force-unwraps. A layout naming art that is not in the bundle is a
        // one-character mistake, and a crash in the middle of a framing run says far less about it
        // than the file name does.
        guard let url = bundledURL(forFileName: fileName) else {
            throw EasyFrameError.fileNotFound("no bundled device frame named \(fileName)")
        }
        guard let image = NSImage(contentsOf: url) else {
            throw EasyFrameError.imageOperationFailure("bundled device frame \(fileName) is unreadable")
        }
        return image
    }

    enum EasyFrameError: Error {
        case fileNotFound(String)
        case imageOperationFailure(String)
        case fileSavingFailure(String)
    }
}
