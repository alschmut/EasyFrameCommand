//
//  Layout.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import SwiftUI

struct Layout {
    /// The bundled bezel art, or `nil` for a page rendered **frameless** — the capture published as
    /// it was taken, on the background, with no device composited over it.
    ///
    /// Vision Pro is the device that needs it. Apple publishes no product bezel for it, and that is
    /// not a gap to work around: a visionOS listing conventionally shows the capture itself, because
    /// the platform's content floats in a room rather than sitting in a device.
    let deviceImageName: String?

    /// The output canvas — the store slot the finished page is uploaded into.
    ///
    /// Before `screenFrame` existed this constant did two jobs at once, and for every frame in this
    /// repository the two answers happen to be the same number. They are not always. A desktop
    /// capture is a *window*, and the window size that fills a MacBook cut-out exactly is not one of
    /// the four sizes App Store Connect accepts for a Mac page, so the page has to be rendered at a
    /// slot size the capture never had. `screenFrame` now owns where the capture is *drawn*; this
    /// owns how big the finished page is.
    let deviceScreenSize: CGSize

    /// Other capture sizes that should resolve to this layout. A capture whose own pixel size is not
    /// the store slot goes here, so the size lookup can still find its frame.
    var additionalScreenSizes: [CGSize] = []

    /// Names that select this layout, compared **case-insensitively for equality** against a
    /// capture file name's device segment — everything before its first `-`.
    ///
    /// Matching by name is what separates devices a pixel size cannot. Apple TV and Vision Pro both
    /// capture at exactly 3840 x 2160 and want opposite treatments, a television bezel against no
    /// bezel at all; no size lookup can tell those two apart.
    ///
    /// It is an equality rather than a substring test, and that is the whole of its safety. A file
    /// named the way `fastlane snapshot` names one — `iPhone 14 Pro Max-1-home.png`, device segment
    /// `iPhone 14 Pro Max` — equals no alias, falls through to `getFirstMatchingLayout(byPixelSize:)`
    /// and resolves exactly as it did before this field existed. A substring test would have caught
    /// it for whichever layout declared `"iphone"` and silently re-framed screenshots nobody asked
    /// to change.
    ///
    /// So: name a capture's device segment for the layout you want, or say nothing and keep the size
    /// lookup you already had. Empty is the default, and every layout that predates this field has
    /// it.
    var deviceNameMatches: [String] = []

    let devicePositioningOffset: CGSize
    let clipCornerRadius: CGFloat

    /// The screen cut-out, in the bezel art's own pixel coordinates, or `nil` to centre the
    /// screenshot under the art.
    ///
    /// Centring is right for art whose hole is centred, which is every frame that shipped before
    /// this field. It is not universal: a render that includes a set-top box and a remote control
    /// beside the television has its screen well off-centre, and centring there puts the whole
    /// screenshot outside the hole it belongs in — inside a frame that still looks entirely correct.
    ///
    /// A wrong rectangle here is invisible in review, so it should not be trusted to review. See
    /// `LayoutTests.screenFrameMatchesTheArtsTransparentHole`, which re-measures every rectangle
    /// declared here against the art's own alpha channel.
    var screenFrame: CGRect?

    /// The region of the raw capture to publish, in the capture's own top-left-origin pixel
    /// coordinates, or `nil` to publish all of it.
    ///
    /// This is a magnifier rather than a trim. A visionOS capture is a photograph of a whole
    /// simulated room with the app window occupying a fraction of the frame, and the page then
    /// scales that capture down to fit the artwork band — so most of the capture's resolution is
    /// spent on ceiling and floor before it ever reaches the store. Cropping to exactly the size the
    /// artwork is drawn at spends those pixels on the app instead, and maps the result 1:1 with
    /// nothing resampled.
    ///
    /// A layout that crops must declare its `deviceScreenSize` as the store slot rather than as the
    /// crop: the canvas is decided before the crop is taken, so a slot equal to the crop would
    /// shrink the finished page.
    var captureCrop: CGRect?

    var isFrameless: Bool { deviceImageName == nil }

    func relative(_ value: CGFloat) -> CGFloat {
        deviceScreenSize.height / 2796 * value
    }

    var allSupportedScreenSizes: [CGSize] {
        [deviceScreenSize] + additionalScreenSizes
    }
}
