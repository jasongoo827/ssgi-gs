#!/usr/bin/env bash
# Assets added for the poster session (2026-11-04), on top of tools/build_assets.sh:
#   video/speed_lego.mp4        GS-IR | GI-GS | Ours replayed at measured frame times, 1280 wide, 60 fps
#                               (60 fps on purpose: at 30 the 20 FPS and 80 FPS panels look alike)
#   video/gigs_vs_ours.mp4      GI-GS | Ours on the moon-rock stage, relit -> direct -> indirect, 1280 wide, 30 fps
#   poster/*.jpg                their poster frames, the poster's qualitative figure
#   env/<name>.jpg              tone-mapped environment-map thumbnails (tools/env_thumbs.py)
# Sources live in the GI-GS repo (docs/poster/videos, docs/poster/figures, datasets/).
set -euo pipefail
G="${1:-$HOME/Workspace/Projects/GI-GS}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/docs/assets"
mkdir -p "$OUT/video" "$OUT/poster" "$OUT/env"
ffmpeg -nostdin -v error -y -i "$G/docs/poster/videos/speed_lego.mp4" -vf scale=1280:-2 -c:v libx264 -crf 22 \
  -preset slow -pix_fmt yuv420p -movflags +faststart "$OUT/video/speed_lego.mp4"
# drop the 2.5 s title card (the page section has its own heading); frames are held x2 at 60 fps, so 30 fps loses nothing
ffmpeg -nostdin -v error -y -ss 2.5 -i "$G/docs/poster/videos/quality_moonrock.mp4" -vf fps=30,scale=1280:-2 -c:v libx264 \
  -crf 22 -preset slow -pix_fmt yuv420p -movflags +faststart "$OUT/video/gigs_vs_ours.mp4"
for v in speed_lego gigs_vs_ours; do
  ffmpeg -nostdin -v error -y -ss 0.5 -i "$OUT/video/$v.mp4" -frames:v 1 -q:v 3 "$OUT/poster/$v.jpg"
done
ffmpeg -nostdin -v error -y -i "$G/docs/poster/figures/qual_lego_relight.png" -vf scale=1600:-2 -q:v 3 "$OUT/poster/qual_lego_fireplace.jpg"
python3 "$(dirname "$0")/env_thumbs.py" "$G/datasets" "$OUT/env"
