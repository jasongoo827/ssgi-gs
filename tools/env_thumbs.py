"""Tone-mapped thumbnails of the environment maps named on the page (equirectangular, 320 x 160).
Each map is exposed to a log-average luminance of 0.18 and Reinhard tone-mapped (x / (1 + x)), then
sRGB-encoded -- enough to recognise a sky; brightness is not comparable between thumbnails.
usage: python3 tools/env_thumbs.py <GI-GS datasets dir> <out dir>
"""
import os, sys
import cv2, numpy as np

TENSOIR = ["sunset", "bridge", "city", "fireplace", "forest", "night", "courtyard", "sunrise", "snow"]
QWANTANI = ["dawn", "morning", "noon", "sunset", "dusk_1", "night"]

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
jobs = [(f"{src}/TensoIR/Environment_Maps/high_res_envmaps_1k/{n}.hdr", n) for n in TENSOIR]
jobs += [(f"{src}/polyhaven/qwantani/qwantani_{n}.hdr", f"qwantani_{n}") for n in QWANTANI]
for path, name in jobs:
    im = cv2.imread(path, cv2.IMREAD_ANYDEPTH | cv2.IMREAD_COLOR)[..., ::-1].astype(np.float32)
    im = cv2.resize(im, (320, 160), interpolation=cv2.INTER_AREA)
    lum = im @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    im = im * (0.18 / np.exp(np.log(lum + 1e-4).mean()))
    im = np.clip(1.6 * im / (1.0 + im), 0, 1)
    im = np.where(im <= 0.0031308, 12.92 * im, 1.055 * im ** (1 / 2.4) - 0.055)
    cv2.imwrite(f"{out}/{name}.jpg", (im[..., ::-1] * 255 + 0.5).astype(np.uint8), [cv2.IMWRITE_JPEG_QUALITY, 88])
    print(name)
