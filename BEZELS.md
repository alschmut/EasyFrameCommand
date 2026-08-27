# Apple product bezels

`Sources/Resources/` holds four PNGs published by Apple. They are **committed**, not fetched at build
time, and they arrive under **Apple licences that put obligations on this repository** — including
one that is the reason this file exists at all. Read § Licences before adding, moving or removing any
of them.

Refresh them with `scripts/fetch-device-bezels.sh`. That is a tool for when Apple ships new hardware,
not a build step.

## What is here

| File | Product | Art | Screen cut-out | Position in the art |
| --- | --- | --- | --- | --- |
| `iPhone 17 Pro Max - Silver - Portrait.png` | iPhone 17 Pro Max, Silver | 1470 x 3000 | **1320 x 2868** | `(75, 66)`, centred |
| `iPad Pro (M5) 13" - Space Black - Portrait.png` | iPad Pro (M5) 13", Space Black | 2300 x 3000 | **2064 x 2752** | `(118, 124)`, centred |
| `MacBook Pro M5 14-inch Space Black.png` | MacBook Pro M5 14", Space Black | 3860 x 2540 | **3024 x 1964** | `(418, 288)`, centred |
| `Apple TV - 4K.png` | Apple TV 4K, with box and Siri Remote | 4300 x 2780 | **3840 x 2158** | `(103, 120)`, **not centred** |

Vision Pro has no row: Apple publishes no product bezel for it, and a visionOS listing conventionally
shows the capture itself. `Layout.visionPro` is frameless.

The six older frames in the same folder — `Apple iPhone 14 Pro Black.png` and its siblings — are
**not** Apple's and are not covered by this file. They came from
[fastlane/frameit-frames](https://github.com/fastlane/frameit-frames) and serve
`.iPhone14ProMax`, `.iPadPro` and `.iPhoneSE3rdGen`.

### Three things that are easy to get wrong

- **Apple TV's cut-out is not centred, and it is not the capture's size.** Its margins are
  L=103 R=357, T=120 B=502 — the box and the remote sit outside the screen, below and to the right —
  which is the whole reason `Layout.screenFrame` exists rather than the screenshot simply being
  centred under the art. The hole is also 3840 x **2158** against a 3840 x 2160 framebuffer, so the
  capture is squashed by two pixels of height. That is 0.09 %, it is invisible, and it is recorded
  here so nobody re-measures it and files a bug.

- **These PNGs are not 72 dpi.** The iPhone render is 216, the iPad and Apple TV 144, the MacBook
  300. `NSImage.size` is in *points*, so the 1470 px iPhone art reports a width of 490 — and framing
  at that number renders the whole composite at a third of its intended size inside a frame that
  looks perfectly correct. Everything downstream uses `NSImage.pixelSize`. The frameit-frames art is
  all 72 dpi, which is why `size` served this package for so long.

- **The measurements above are re-derived by a test, not trusted.** `LayoutTests`'
  `screenFrameMatchesTheArtsTransparentHole` flood-fills each PNG's alpha channel outward from the
  centre of the image over fully transparent pixels and asserts the bounding box against the declared
  `Layout.screenFrame`. A wrong offset produces a run that succeeds, a frame that looks like the
  device it is, and a screenshot in the wrong place — so it is checked rather than reviewed.

## Finishes

A bezel has to separate from the page background behind it without competing with the screenshot
inside it, so the right finish depends on the background. These four were picked against a dark
indigo (`#182061`):

- **iPhone 17 Pro Max Silver.** All three Pro Max finishes were composited against that indigo. Deep
  Blue merges into it and the device stops reading as a device; Cosmic Orange fights a blue accent in
  the content. Silver separates from the background without competing with it.
- **iPad Pro 13" and MacBook Pro 14" in Space Black**, the darker finish Apple offers for each, which
  reads as a body rather than a bright edge at thumbnail size.
- **Apple TV** ships a single variant.

Against a light background the answers would likely be different. Re-composite rather than inherit.

## Provenance

Downloaded from Apple's design resources CDN by `scripts/fetch-device-bezels.sh`:

| Archive | Source |
| --- | --- |
| `Bezel-iPhone-17.dmg` | `https://devimages-cdn.apple.com/design/resources/download/Bezel-iPhone-17.dmg` |
| `Bezel-iPad-Pro-(M5).dmg` | `…/Bezel-iPad-Pro-(M5).dmg` |
| `Bezel-MacBook-Pro-M5.dmg` | `…/Bezel-MacBook-Pro-M5.dmg` |
| `Bezel-Apple-TV.dmg` | `…/Bezel-Apple-TV.dmg` |

Listed at <https://developer.apple.com/design/resources/#product-bezels>. Fetched 2026-08-26.

## Licences

**The four files do not all arrive under the same agreement**, which is easy to miss because they
come from one page and one script.

| Files | Agreement | Version |
| --- | --- | --- |
| iPhone, iPad, MacBook Pro | *Apple Inc. License Agreement for Apple Design Resources* | LYL142, 06/21/2023 |
| Apple TV | *App Store Marketing Artwork License Agreement* | EA0861, 08/15/17 |

Each disk image carries its own copy at the top level; read them there rather than trusting this
summary. What actually constrains a repository carrying these files:

**Apple Design Resources License, § 2A — what the grant is for.** A limited, non-transferable,
non-exclusive licence to use the resources *solely for creating mock-ups of user interfaces for
software that runs only on Apple's platforms*, including the right to show them in screenshots and
images of those mock-ups. Framed App Store screenshots for an Apple-platform app are squarely that.

**§ 2B — what it is not for.** "You may not embed the Apple Design Resources in any software programs
or other products", and they may not be rented, lent, transferred, sublicensed or otherwise
redistributed. Committing the PNGs into `Sources/Resources/` puts them in the bundle of a
**command-line tool that generates mock-ups**, which is the use § 2A describes — not in a shipping
application. Do not link this package into an app target and do not copy the art into one.

**§ 2C — the obligation this file discharges.** "To the extent that you provide Mock-Ups you create
using the Template Content to any other party, you agree to ensure that each such recipient is aware
of the restrictions set forth in this License." Publishing framed screenshots to the App Store, and
handing this repository to anyone, are both that. So: **if you are reading this, the artwork in
`Sources/Resources/` named in the table above is Apple's, licensed for Apple-platform UI mock-ups
only, and may not be extracted, modified, redistributed or repackaged as clip art or stock assets.**

**§ 3 — no separation from the bundle.** "All components of the Apple Design Resources are provided
as part of a bundle and may not be separated from the bundle and distributed on a standalone basis."
Taking one PNG out of each disk image is a tension worth naming rather than glossing: the reading
this file works on is that the extracted file remains covered by the same licence, remains in service
of the same permitted mock-up use, and is not being distributed *as artwork*. If that reading ever
needs to be firmer, the fix is to stop committing the PNGs and make `scripts/fetch-device-bezels.sh`
a prerequisite of a framing run instead — which costs a ~330 MB download per fresh checkout, and is
why it was not done that way.

**Marketing Artwork Agreement (Apple TV), §§ 1–2.** The grant is narrower in one respect worth
knowing: it covers use "only in connection with Your applications that are available for download on
the App Store" and "only while You are a member of the Apple Developer Program", in compliance with
the App Store Marketing and Advertising Guidelines. If you are not an Apple Developer Program member
shipping to the App Store, that frame is not licensed to you.

**This repository's own licence does not extend to these files.** The MIT terms in `LICENSE` cover
the source; Apple retains ownership of the artwork (Design Resources § 1A; Marketing § 6) and it
reaches you only under the agreements above.

## Refreshing

```bash
./scripts/fetch-device-bezels.sh
swift test     # re-measures every cut-out
```

The script downloads the four archives, mounts each accepting its licence, and copies exactly one PNG
out of each. Then **run the tests**: a new hardware generation almost always moves the cut-out, and
`Layout.screenFrame` is a hand-transcribed rectangle that the test is the only thing checking.

If the script dies with "no longer contains", Apple has renamed the file inside the archive — which
usually means the art was redrawn. List the image's `PNG/` folder, update `BEZELS` in the script,
update the layout, and let the test tell you the new rectangle.
