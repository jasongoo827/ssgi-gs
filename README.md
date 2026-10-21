# ssgi-gs — project page

Project page for *Screen-Space Global Illumination for Real-Time Relightable Gaussian
Inverse Rendering*. Published with GitHub Pages from `main` / `docs`:

    https://jasongoo827.github.io/ssgi-gs/

## Layout

    docs/            the site itself (Pages serves this folder)
      index.html     one page, no framework, no build step
      style.css
      app.js         object pickers + play-only-what-is-visible
      assets/        generated -- see below
      .nojekyll      stops GitHub from running the files through Jekyll
    tools/
      build_assets.sh   source clips -> docs/assets

## Rebuilding the media

The clips come from the GI-GS research repo (`outputs/demo/video/`), which is not public.

    tools/build_assets.sh [SRC_DIR]     # default: ~/Workspace/Projects/GI-GS/outputs/demo/video

It remuxes each clip with `+faststart` (stream copy -- no re-encode) so playback starts
before the download finishes, and grabs frame 0 as a poster image. ~31 MB in total.

## Things that will break the site if forgotten

- **Never put the clips in Git LFS.** Pages serves the LFS pointer file, not the video.
- **Relative paths only.** The site lives under `/ssgi-gs/`, so a leading `/` is a 404 in
  production even though it works locally.
- Keep `docs/.nojekyll` in place.

## Local preview

    python3 -m http.server -d docs 8000     # then open http://localhost:8000/
