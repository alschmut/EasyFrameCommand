//
//  SupportedDevice.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import Foundation

enum SupportedDevice: CaseIterable {
    case iPhone14ProMax
    case iPadPro
    case iPhoneSE3rdGen
    /// Five Apple platforms in Apple's own product bezels, plus the one Apple publishes no bezel
    /// for. Declared **after** the three above so the pixel-size lookup keeps answering the way it
    /// always did; they are reached by name instead. See `Layout.deviceNameMatches`.
    case iPhone17ProMax
    case iPadPro13M5
    case macBookPro14
    case appleTV4K
    case visionPro

    var layout: Layout {
        switch self {
        case .iPhone14ProMax: .iPhone14ProMax
        case .iPadPro: .iPadPro
        case .iPhoneSE3rdGen: .iPhoneSE3rdGen
        case .iPhone17ProMax: .iPhone17ProMax
        case .iPadPro13M5: .iPadPro13M5
        case .macBookPro14: .macBookPro14
        case .appleTV4K: .appleTV4K
        case .visionPro: .visionPro
        }
    }
    
    static func getFirstMatchingLayout(byPixelSize pixelSize: CGSize) -> Layout? {
        SupportedDevice.allCases.first(where: { device in
            device.layout.allSupportedScreenSizes.contains(pixelSize)
        })?.layout
    }

    /// The layout whose `deviceNameMatches` names this capture's device segment — the part of the
    /// file name before its first `-`.
    ///
    /// Tried before `getFirstMatchingLayout(byPixelSize:)`, because some devices cannot be told
    /// apart by size at all: Apple TV and Vision Pro both capture at exactly 3840 x 2160. A layout
    /// that declares no aliases is unreachable this way and keeps the size lookup it always had,
    /// which is what stops a new layout quietly taking over an old one's screenshots.
    static func layout(forDeviceName name: String) -> Layout? {
        let needle = name.lowercased()
        return allCases.first { device in
            device.layout.deviceNameMatches.contains { $0.lowercased() == needle }
        }?.layout
    }
}

private extension Layout {
    
    /// The iPhone 14 Pro Max frame is also used for screenshots made with an iPhone 15, 16 and 17 Pro Max
    /// The `FramedScreenshotView` will show a slightly downscaled version of the screenshot
    static let iPhone14ProMax = Self(
        deviceImageName: "Apple iPhone 14 Pro Max Black.png",
        deviceScreenSize: .iPhone14ProMax,
        additionalScreenSizes: [
            .iPhone15ProMax,
            .iPhone16ProMax,
            .iPhone17ProMax
        ],
        devicePositioningOffset: .init(width: 0, height: 2),
        clipCornerRadius: 35
    )

    static let iPadPro = Self(
        deviceImageName: "Apple iPad Pro (12.9-inch) (4th generation) Space Gray.png",
        deviceScreenSize: .iPadPro6thGen13Inch,
        additionalScreenSizes: [
            .iPadPro13Inch
        ],
        devicePositioningOffset: .init(width: 2, height: 0),
        clipCornerRadius: 35
    )

    static let iPhoneSE3rdGen = Self(
        deviceImageName: "Apple iPhone SE Black.png",
        deviceScreenSize: .iPhoneSE3rdGen,
        devicePositioningOffset: .init(width: 0, height: 2),
        clipCornerRadius: 0
    )

    // MARK: - Apple product bezels
    //
    // Four PNGs published by Apple, downloaded by `scripts/fetch-device-bezels.sh` and committed to
    // `Sources/Resources/`. **Their provenance and their licence terms are in `BEZELS.md`, which is
    // required reading before touching any of this** — the art arrives under two different Apple
    // agreements, it may not be embedded in a software product, and anyone handed work made with it
    // has to be told about the restrictions.
    //
    // Every `screenFrame` below is a *measured* rectangle, not a derived one: the art is flood-filled
    // from its centre over `alpha == 0` and the hole's bounding box is what is written here.
    // `screenFrameMatchesTheArtsTransparentHole` re-does that measurement on every test run, because
    // a wrong offset produces a run that succeeds, a frame that looks like the device it is, and a
    // screenshot in the wrong place.
    //
    // `clipCornerRadius` is **belt-and-braces** throughout. The bezel is composited *over* the
    // screenshot, so the art's own alpha is what actually shapes the screen; the clip only matters if
    // it is set larger than the hole's corner, which would cut into visible screen. Each value below
    // is deliberately under the measured corner inset.

    /// iPhone 17 Pro Max, Silver. Art 1470 x 3000, cut-out exactly the portrait capture, so nothing
    /// is resampled — where `.iPhone14ProMax` downscales a modern capture into an older hole.
    static let iPhone17ProMax = Self(
        deviceImageName: "iPhone 17 Pro Max - Silver - Portrait.png",
        deviceScreenSize: .iPhone17ProMax,
        // Only the bare device word, on purpose. `"iphone 17 pro max"` is *not* here: that is a name
        // `fastlane snapshot` really writes, and claiming it would take a 17 Pro Max capture away
        // from `.iPhone14ProMax`, which serves it today via `additionalScreenSizes`. Opting in is
        // the caller's to do, not this layout's to assume.
        deviceNameMatches: ["iphone"],
        devicePositioningOffset: .zero,
        // Measured corner inset ~250 px; the screen is a squircle rather than a circular arc, so
        // this stays comfortably under it.
        clipCornerRadius: 200,
        screenFrame: CGRect(x: 75, y: 66, width: 1320, height: 2868)
    )

    /// iPad Pro (M5) 13", Space Black. Art 2300 x 3000, cut-out exactly the portrait capture.
    ///
    /// Apple ships a **native landscape** render of this device too, which is a better frame than
    /// rotating this one a quarter-turn; it would be one more PNG and one more layout, not a
    /// `CGContext` pass.
    static let iPadPro13M5 = Self(
        deviceImageName: "iPad Pro (M5) 13\" - Space Black - Portrait.png",
        deviceScreenSize: .iPadPro13Inch,
        // As above: no product-name alias, because `.iPadPro` already answers 2064 x 2752.
        deviceNameMatches: ["ipad"],
        devicePositioningOffset: .zero,
        // Measured corner inset 61 px.
        clipCornerRadius: 50,
        screenFrame: CGRect(x: 118, y: 124, width: 2064, height: 2752)
    )

    /// MacBook Pro M5 14", Space Black. Art 3860 x 2540.
    ///
    /// **The layout whose canvas is not its capture's size**, and the reason `deviceScreenSize` and
    /// `screenFrame` had to become two things. A desktop capture is a *window*: size it to
    /// 1512 x 982 pt and it comes out 3024 x 1964 px, which lands in this cut-out untouched — but
    /// 3024 x 1964 is not an `APP_DESKTOP` size at all. App Store Connect takes 1280x800, 1440x900,
    /// 2560x1600 and 2880x1800 and refuses everything else. So the page is rendered at the slot and
    /// the capture's own size rides in `additionalScreenSizes`.
    static let macBookPro14 = Self(
        deviceImageName: "MacBook Pro M5 14-inch Space Black.png",
        deviceScreenSize: .macStore,
        additionalScreenSizes: [
            .macBookPro14Display
        ],
        deviceNameMatches: ["mac", "macbook", "macbook pro"],
        devicePositioningOffset: .zero,
        // Measured corner inset 50 px.
        clipCornerRadius: 40,
        screenFrame: CGRect(x: 418, y: 288, width: 3024, height: 1964)
    )

    /// Apple TV 4K — the box, the Siri Remote and a television, in one render. Art 4300 x 2780.
    ///
    /// **The cut-out that is not centred in its art**, and the reason `Layout.screenFrame` exists:
    /// L=103 R=357, T=120 B=502, because the box and the remote sit outside the screen, below and to
    /// the right. Centring here would put the whole screenshot 127 px left and 191 px high of the
    /// hole it belongs in, inside a frame that still looked perfectly correct.
    ///
    /// It is also the only cut-out that does not match its capture exactly: 3840 x **2158** against a
    /// 3840 x 2160 framebuffer, so the shot is squashed by two pixels of height. That is 0.09 %, it
    /// is invisible, and it is recorded so nobody re-measures it and files a bug.
    static let appleTV4K = Self(
        deviceImageName: "Apple TV - 4K.png",
        deviceScreenSize: .appleTVStore,
        deviceNameMatches: ["appletv", "apple tv", "apple tv 4k", "apple tv 4k (3rd generation)"],
        devicePositioningOffset: .zero,
        // Measured square: unlike the other three, this hole has no rounded corner to respect.
        clipCornerRadius: 0,
        screenFrame: CGRect(x: 103, y: 120, width: 3840, height: 2158)
    )

    /// Apple Vision Pro — **frameless**. `deviceImageName` is `nil` and the capture is published as
    /// it was taken, rendered as a card.
    ///
    /// Apple publishes no Vision Pro product bezel, and that is not a gap to work around: a visionOS
    /// listing conventionally shows the capture itself, because the platform's content floats in a
    /// room rather than sitting in a device.
    ///
    /// **The name is the only thing that can select this layout**, which is the case that made
    /// `deviceNameMatches` necessary. Vision Pro and Apple TV both capture at exactly 3840 x 2160,
    /// `.appleTV4K` is declared first, and a size lookup would hand every visionOS capture a
    /// television.
    ///
    /// `captureCrop` is a magnifier, not a trim: a visionOS capture is a photograph of a whole
    /// simulated room with the app window occupying about 45 % of the frame, and 2654 x 1493 is
    /// exactly the size the card is drawn at inside a 3840 x 2160 page — so the crop maps 1:1 and
    /// nothing is resampled. The origin is measured, by differencing pairs of captures to separate
    /// the app's content from the room behind it.
    static let visionPro = Self(
        deviceImageName: nil,
        // The store slot, **not** the crop — the canvas is decided before the crop is taken.
        deviceScreenSize: .visionProStore,
        additionalScreenSizes: [.visionProSimulator],
        deviceNameMatches: ["visionpro", "vision pro", "apple vision pro"],
        devicePositioningOffset: .zero,
        // Unused while frameless: the card's corners come from `ScreenshotDesignView`.
        clipCornerRadius: 0,
        captureCrop: CGRect(x: 521, y: 430, width: 2654, height: 1493)
    )
}

private extension CGSize {
    static let iPhone17ProMax = CGSize(width: 1320, height: 2868)
    static let iPhone16ProMax = CGSize(width: 1320, height: 2868)
    static let iPhone15ProMax = CGSize(width: 1290, height: 2796)
    static let iPhone14ProMax = CGSize(width: 1290, height: 2796)
    static let iPadPro6thGen13Inch = CGSize(width: 2048, height: 2732)
    static let iPadPro13Inch = CGSize(width: 2064, height: 2752)
    static let iPhoneSE3rdGen = CGSize(width: 750, height: 1334)

    /// The MacBook Pro 14" bezel's cut-out, which is the window size a desktop capture is pinned to.
    static let macBookPro14Display = CGSize(width: 3024, height: 1964)
    /// App Store Connect's `APP_DESKTOP` slot. 1280x800, 1440x900 and 2560x1600 are also accepted;
    /// 2880x1800 is the largest and everything else scales down from it cleanly.
    static let macStore = CGSize(width: 2880, height: 1800)

    /// App Store Connect's `APP_APPLE_TV` slot, and what the Apple TV 4K simulator captures. The
    /// bezel's hole is two pixels shorter; that number lives in `.appleTV4K`'s `screenFrame`.
    static let appleTVStore = CGSize(width: 3840, height: 2160)

    /// App Store Connect's `APP_APPLE_VISION_PRO` slot.
    static let visionProStore = CGSize(width: 3840, height: 2160)
    /// What the Apple Vision Pro simulator captures on some runtimes — the same 16:9 shape.
    static let visionProSimulator = CGSize(width: 2732, height: 2048)
}
