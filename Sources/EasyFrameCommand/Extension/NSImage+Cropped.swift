//
//  NSImage+Cropped.swift
//  easy-frame
//

import SwiftUI

extension NSImage {

    /// A pixel-exact crop, in the image's own **top-left-origin** pixel coordinates.
    ///
    /// **The source pixels come from the bitmap representation, not from
    /// `cgImage(forProposedRect:context:hints:)`**, and the result is rebuilt through an explicit
    /// `NSBitmapImageRep` rather than `NSImage(cgImage:size:)`. Both of those APIs answer with the
    /// *display's* backing resolution rather than the image's, so on a Retina Mac a correct crop
    /// would report twice its true pixel size and everything downstream would be laid out at half
    /// scale inside a page that still looks correct.
    func cropped(to rect: CGRect) -> NSImage {
        guard let cgImage = representations
            .compactMap({ $0 as? NSBitmapImageRep })
            .first?
            .cgImage,
            // `CGImage.cropping(to:)` already works in top-left-origin pixel coordinates — the
            // bitmap's own space — so there is no flip to do here. It returns `nil` for a rect that
            // does not intersect the image, which a layout's crop never should; the guard hands back
            // the uncropped image rather than failing the run.
            let cropped = cgImage.cropping(to: rect)
        else {
            return self
        }

        let size = CGSize(width: cropped.width, height: cropped.height)
        let representation = NSBitmapImageRep(cgImage: cropped)
        representation.size = size

        let image = NSImage(size: size)
        image.addRepresentation(representation)
        return image
    }
}
