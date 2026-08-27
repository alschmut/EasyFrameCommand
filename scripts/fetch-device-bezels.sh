#!/bin/bash
#
# Refreshes the Apple product bezels the framing step composites over each capture.
#
#   ./scripts/fetch-device-bezels.sh
#
# **This is not a build step.** The four PNGs are committed to `Sources/Resources/` and `easy-frame`
# reads them from its bundle. Run this when Apple ships new hardware and the lineup should wear it —
# not before every capture.
#
# Downloading is ~330 MB, almost all of it the iPhone archive, which carries every 17-family model
# in six finishes and two orientations. One PNG is taken from each disk image and the rest is
# discarded.
#
# MARK: - Licence
#
# The four files arrive under **two different Apple licences** — see `BEZELS.md`, which is where the
# terms and the obligations they put on this repository are recorded. In short:
# the artwork is licensed for mock-ups of Apple-platform software, may not be embedded in a
# software product, and anyone handed a mock-up made with it has to be told about the restrictions.
# That last one is why BEZELS.md exists at all.
#
# Both licences are accepted non-interactively below (`yes | hdiutil attach`), which is the same
# agreement a person clicks through in the Finder. Read them before running this if you have not:
# each disk image carries its own at the top level.
#
set -euo pipefail

cd "$(dirname "$0")/.."

DESTINATION="Sources/Resources"
BASE_URL="https://devimages-cdn.apple.com/design/resources/download"

# archive | path of the wanted PNG inside the mounted image
#
# The finishes are **choices, not defaults** — a bezel has to separate from the page background
# behind it without competing with the screenshot inside it, and which finish does that depends on
# the background. See BEZELS.md § Finishes for how the ones below were picked.
#
# The Apple TV image ships a single variant, so its path names no finish.
declare -a BEZELS=(
    "Bezel-iPhone-17|PNG/iPhone 17 Pro Max/iPhone 17 Pro Max - Silver - Portrait.png"
    "Bezel-iPad-Pro-(M5)|PNG/iPad Pro (M5) 13\" - Space Black - Portrait.png"
    "Bezel-MacBook-Pro-M5|PNG/MacBook Pro M5 14-inch Space Black.png"
    "Bezel-Apple-TV|PNG/Apple TV - 4K.png"
)

log() { echo "bezels: $*"; }
die() { echo "error: $*" >&2; exit 1; }

work_directory="$(mktemp -d)"
mounted=()

# Detach every image this run mounted, whatever it exits by. A left-behind mount is not harmless:
# the next run's `hdiutil attach` on the same image fails rather than reusing it.
cleanup() {
    for mount_point in "${mounted[@]+"${mounted[@]}"}"; do
        hdiutil detach "$mount_point" -quiet >/dev/null 2>&1 || true
    done
    rm -rf "$work_directory"
}
trap cleanup EXIT

[[ -d "$DESTINATION" ]] || die "no $DESTINATION — run this from a checkout of the repository."

for entry in "${BEZELS[@]}"; do
    IFS='|' read -r archive wanted <<< "$entry"

    local_dmg="$work_directory/$archive.dmg"
    mount_point="$work_directory/mnt-$archive"

    log "$archive → downloading"
    curl -fsSL --retry 2 -o "$local_dmg" "$BASE_URL/$archive.dmg" \
        || die "could not download $BASE_URL/$archive.dmg"

    mkdir -p "$mount_point"
    # Registered **before** the attach, not after. `hdiutil` mounts the image and *then* reports
    # failure for reasons of its own (see the subshell below), and a mount point the trap does not
    # know about is one `rm -rf "$work_directory"` walks straight into — 3 800 lines of
    # "Read-only file system" and a disk image still attached at the end of the run.
    mounted+=("$mount_point")

    # `yes` answers the licence agreement, and `PAGER=cat` stops `hdiutil` paging it into a
    # terminal that has nobody reading it. This is the same acceptance the Finder collects.
    #
    # **The subshell drops `pipefail`, and that is the whole point of it.** `hdiutil` stops reading
    # once it has its answer, so `yes` dies of `SIGPIPE` with status 141 — and under `pipefail`
    # that, not `hdiutil`'s 0, becomes the pipeline's status. The mount succeeds and the script
    # calls it a failure.
    ( set +o pipefail; yes | PAGER=cat hdiutil attach -nobrowse -readonly -noverify \
        -mountpoint "$mount_point" "$local_dmg" >/dev/null 2>&1 ) \
        || die "could not mount $local_dmg"

    [[ -f "$mount_point/$wanted" ]] \
        || die "$archive no longer contains '$wanted'.
Apple renames these between hardware generations. List the image's PNG folder and update BEZELS
above, then re-measure the cut-out — 'Layout.screenFrame' is in the art's own coordinates and a
renamed file is usually a re-drawn one."

    cp "$mount_point/$wanted" "$DESTINATION/$(basename "$wanted")"
    log "$archive → $(basename "$wanted")"
done

log "wrote ${#BEZELS[@]} bezels to $DESTINATION"
log "now run 'swift test': screenFrameMatchesTheArtsTransparentHole asserts each declared"
log "'Layout.screenFrame' against the art's real transparent hole, and new hardware usually moves it."
