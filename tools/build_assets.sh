#!/usr/bin/env bash
# Build the page's media assets from the GI-GS demo renders.
#
#   tools/build_assets.sh [SRC_DIR]
#
# For every clip in the manifest below this does two things:
#   1. remux to docs/assets/video/<obj>_<kind>.mp4 with +faststart, so the
#      browser can start playing before the whole file has arrived. This is a
#      stream copy -- no re-encode, no quality loss.
#   2. grab frame 0 as docs/assets/poster/<obj>_<kind>.jpg, shown while the
#      video is still loading.
#
# Re-run it whenever a source clip is re-rendered; outputs are overwritten.
set -euo pipefail

SRC="${1:-$HOME/Workspace/Projects/GI-GS/outputs/demo/video}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/docs/assets"

# <obj>_<kind>  <source file>
#   rotation   : 1 sky | 5 skies | GT, sky rotating +-60 deg
#   day        : 5 skies | GT, dawn -> moonlit night
#   components : direct | indirect | final
# lego predates the obj_* naming convention, hence the odd source names; its
# rotation clip is 2 columns (5 skies | GT) where the others are 3.
MANIFEST="
lego_rotation        video_lego_rotation.mp4
lego_day             video8_lego_day.mp4
lego_components      video3_direct_indirect_final.mp4
hotdog_rotation      video_hotdog_rotation.mp4
hotdog_day           video_hotdog_day.mp4
hotdog_components    video_hotdog_components.mp4
ficus_rotation       video_ficus_rotation.mp4
ficus_day            video_ficus_day.mp4
ficus_components     video_ficus_components.mp4
armadillo_rotation   video_armadillo_rotation.mp4
armadillo_day        video_armadillo_day.mp4
armadillo_components video_armadillo_components.mp4
bust_rotation        video_bust_rotation.mp4
bust_day             video_bust_day.mp4
bust_components      video_bust_components.mp4
moonrock_rotation    video_moonrock_rotation.mp4
moonrock_day         video_moonrock_day.mp4
moonrock_components  video_moonrock_components.mp4
"

mkdir -p "$OUT/video" "$OUT/poster"
missing=0

while read -r name src; do
    [ -z "$name" ] && continue
    if [ ! -f "$SRC/$src" ]; then
        echo "MISSING  $SRC/$src" >&2
        missing=$((missing + 1))
        continue
    fi
    ffmpeg -nostdin -v error -y -i "$SRC/$src" -c copy -movflags +faststart "$OUT/video/$name.mp4"
    ffmpeg -nostdin -v error -y -i "$SRC/$src" -frames:v 1 -vf scale=1440:-2 -q:v 4 "$OUT/poster/$name.jpg"
    printf '%-22s %6s KiB  +  %4s KiB poster\n' "$name" \
        "$(( $(stat -c%s "$OUT/video/$name.mp4") / 1024 ))" \
        "$(( $(stat -c%s "$OUT/poster/$name.jpg") / 1024 ))"
done <<< "$MANIFEST"

echo
echo "total $(du -sh "$OUT" | cut -f1) in $OUT"
[ "$missing" -gt 0 ] && { echo "$missing source clip(s) missing" >&2; exit 1; }
exit 0
