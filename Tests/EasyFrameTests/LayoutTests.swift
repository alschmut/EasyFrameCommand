//
//  LayoutTests.swift
//  easy-frame
//
//  A framing run has an unusual failure mode: almost everything that can go wrong still produces a
//  finished JPEG at the right size, with a device frame that looks exactly like the device it is.
//  The screenshot inside it is simply in the wrong place, or the wrong scale, or the frame is a
//  slightly different model than the capture came from. None of that survives a glance at the
//  finished page — and none of it is visible in a diff either, because what changed is a rectangle
//  of numbers transcribed by hand from a picture.
//
//  So these tests measure rather than review. The one that matters most re-derives every declared
//  `Layout.screenFrame` from the art's own alpha channel and asserts the two agree; it caught a real
//  mistake on its first run.
//

import Testing
import AppKit
@testable import easy_frame

/// One name per layout that declares aliases — the part of a capture's file name before its first
/// `-`, which is what `getDeviceLayout(deviceName:pixelSize:)` looks up.
private let namedDevices = ["iPhone", "iPad", "Mac", "VisionPro", "AppleTV"]

@Suite("Device frames")
struct LayoutTests {

    /// A framed layout has to name art that is actually in the bundle. `getBundledNSImage` throws
    /// on a miss rather than force-unwrapping, so a one-character typo in a file name is a message
    /// instead of a crash — and this catches it before a framing run starts at all.
    @Test("every framed layout's art is present")
    func bundledArtResolves() throws {
        for device in SupportedDevice.allCases where !device.layout.isFrameless {
            let name = try #require(device.layout.deviceImageName)
            #expect(
                FileHelper.bundledURL(forFileName: name) != nil,
                "\(device) names bezel art that is not in the bundle: \(name)"
            )
        }
    }

    /// Every capture size these layouts are meant to serve has to find one, or a framing run throws
    /// `deviceFrameNotSupported` after a capture run has already spent its minutes.
    ///
    /// The Mac is here twice over, and the pair is the point: 2880 x 1800 is the store slot its page
    /// is rendered at, and 3024 x 1964 is the window it captures. The two differ because that window
    /// size is not an `APP_DESKTOP` size, so the capture's own size has to ride in
    /// `additionalScreenSizes` for a size lookup to find the layout at all.
    @Test(
        "the store sizes all resolve to a layout",
        arguments: [
            CGSize(width: 1320, height: 2868),   // iPhone 17 Pro Max
            CGSize(width: 2064, height: 2752),   // iPad Pro 13-inch
            CGSize(width: 2880, height: 1800),   // MacBook Pro 14-inch — the APP_DESKTOP slot
            CGSize(width: 3024, height: 1964),   // MacBook Pro 14-inch — the capture window
            CGSize(width: 3840, height: 2160)    // Apple TV and Vision Pro
        ]
    )
    func storeSizesResolve(size: CGSize) {
        #expect(SupportedDevice.getFirstMatchingLayout(byPixelSize: size) != nil)
    }

    /// Every layout that means to be reachable by name has to actually be reachable by name, because
    /// for Apple TV and Vision Pro nothing else can tell them apart — both capture at exactly
    /// 3840 x 2160.
    ///
    /// The match is an equality, so a typo in `deviceNameMatches` fails here rather than silently
    /// falling through to the size lookup and framing a visionOS capture in a television.
    @Test("every named device resolves", arguments: namedDevices)
    func deviceNamesResolve(name: String) {
        #expect(SupportedDevice.layout(forDeviceName: name) != nil)
    }

    /// A crop has to fit inside the capture it crops, and keep the store slot's shape.
    ///
    /// Both halves matter. A rect that runs off the edge makes `CGImage.cropping(to:)` return `nil`,
    /// which `NSImage.cropped(to:)` answers by handing back the *uncropped* image — so the run
    /// succeeds and quietly publishes the wide shot. And because the page draws the crop
    /// `scaledToFit`, an aspect ratio that drifts from the slot's stops the 1:1 mapping the crop
    /// exists to get, leaving the capture resampled again for no gain.
    @Test("every capture crop fits its capture and keeps the slot's aspect", arguments: namedDevices)
    func captureCropsFitTheCapture(name: String) throws {
        let layout = try #require(SupportedDevice.layout(forDeviceName: name))
        guard let crop = layout.captureCrop else { return }

        let capture = layout.deviceScreenSize
        #expect(crop.minX >= 0 && crop.minY >= 0, "\(name): crop starts outside the capture")
        #expect(
            crop.maxX <= capture.width && crop.maxY <= capture.height,
            "\(name): crop \(crop) runs off a \(capture) capture"
        )

        let cropAspect = crop.width / crop.height
        let slotAspect = capture.width / capture.height
        #expect(
            abs(cropAspect - slotAspect) < 0.01,
            "\(name): crop is \(cropAspect) where the slot is \(slotAspect)"
        )
    }

    /// **The test that makes a wrong offset unshippable.**
    ///
    /// `Layout.screenFrame` is a rectangle in the bezel art's own coordinates, transcribed by hand
    /// from a measurement. Get it wrong and the run still succeeds, the frame still looks like the
    /// device it is, and the screenshot inside it is simply in the wrong place — the exact class of
    /// bug that survives review. So the measurement is re-done here, from the art itself: flood-fill
    /// the alpha channel outward from the centre of the image over fully transparent pixels, and
    /// the bounding box of what is reached is the hole.
    ///
    /// Re-run it after `scripts/fetch-device-bezels.sh`: a new hardware generation almost always
    /// moves the cut-out, and this is the only thing checking.
    ///
    /// Starting at the centre matters. The art is *also* transparent everywhere outside the device
    /// body, so an alpha bounding box over the whole image would answer with the whole image; only
    /// a fill enclosed by the opaque body finds the screen.
    @Test("every framed layout's screenFrame is the art's real transparent hole", arguments: namedDevices)
    func screenFrameMatchesTheArtsTransparentHole(name: String) throws {
        let layout = try #require(SupportedDevice.layout(forDeviceName: name))
        guard !layout.isFrameless else { return }

        let declared = try #require(
            layout.screenFrame,
            "\(name) is framed but declares no screenFrame, so its screenshot would be centred"
        )
        let artName = try #require(layout.deviceImageName)
        let art = try FileHelper.getBundledNSImage(fromFileName: artName)

        let measured = try #require(
            transparentHole(in: art),
            "\(artName) has no enclosed transparent region at its centre — is it really a bezel?"
        )

        #expect(
            measured == declared,
            "\(name): \(artName) has its cut-out at \(measured), but the layout declares \(declared)"
        )
    }
}

// MARK: - Measuring the art

/// The alpha channel as a top-down row-major buffer of the image's true pixels.
///
/// Drawn through a `CGContext` from the **bitmap representation**, not from
/// `cgImage(forProposedRect:context:hints:)`: that rasterises against the current device and hands
/// back a 2x render on a Retina Mac, so the same art would measure differently on two machines.
private func alphaChannel(of image: NSImage) -> (width: Int, height: Int, alpha: [UInt8])? {
    guard let cgImage = image.representations
        .compactMap({ $0 as? NSBitmapImageRep })
        .first?
        .cgImage
    else {
        return nil
    }

    let width = cgImage.width
    let height = cgImage.height
    var buffer = [UInt8](repeating: 0, count: width * height * 4)

    let drawn: Bool = buffer.withUnsafeMutableBytes { raw in
        guard let context = CGContext(
            data: raw.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return false
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return true
    }
    guard drawn else { return nil }

    // **No vertical flip.** A `CGContext`'s *drawing* origin is bottom-left, which invites one —
    // but a bitmap context's *memory* is top-down, so row 0 already holds the image's top row, and
    // that is the coordinate system `Layout.screenFrame` and SwiftUI's `.offset` both use. Flipping
    // here mirrors Apple TV's hole from y=120 to y=502 and leaves the other three looking correct,
    // because theirs are the only margins in the set that are symmetric.
    var alpha = [UInt8](repeating: 0, count: width * height)
    for index in 0..<(width * height) {
        alpha[index] = buffer[index * 4 + 3]
    }
    return (width, height, alpha)
}

/// The bounding box of the fully transparent region enclosing the image's centre, or `nil` if the
/// centre is opaque.
private func transparentHole(in image: NSImage) -> CGRect? {
    guard let (width, height, alpha) = alphaChannel(of: image) else { return nil }

    let start = (height / 2) * width + (width / 2)
    guard alpha[start] == 0 else { return nil }

    var seen = [Bool](repeating: false, count: width * height)
    // An index-based queue with a read head, not `removeFirst()`: these images run to twelve
    // million pixels and `Array.removeFirst` is linear, which turns the fill quadratic.
    var queue = [Int32(start)]
    var head = 0
    seen[start] = true

    var minX = width, maxX = 0, minY = height, maxY = 0

    while head < queue.count {
        let index = Int(queue[head])
        head += 1
        let x = index % width
        let y = index / width
        if x < minX { minX = x }
        if x > maxX { maxX = x }
        if y < minY { minY = y }
        if y > maxY { maxY = y }

        if x > 0, !seen[index - 1], alpha[index - 1] == 0 {
            seen[index - 1] = true
            queue.append(Int32(index - 1))
        }
        if x < width - 1, !seen[index + 1], alpha[index + 1] == 0 {
            seen[index + 1] = true
            queue.append(Int32(index + 1))
        }
        if y > 0, !seen[index - width], alpha[index - width] == 0 {
            seen[index - width] = true
            queue.append(Int32(index - width))
        }
        if y < height - 1, !seen[index + width], alpha[index + width] == 0 {
            seen[index + width] = true
            queue.append(Int32(index + width))
        }
    }

    return CGRect(
        x: CGFloat(minX),
        y: CGFloat(minY),
        width: CGFloat(maxX - minX + 1),
        height: CGFloat(maxY - minY + 1)
    )
}
