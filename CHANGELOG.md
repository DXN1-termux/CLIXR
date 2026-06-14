# Changelog

All notable changes to **clixr** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/).

## [0.2.0] — Unreleased

### Added
- **`curl`** — a fancy HTTP client/downloader: methods, repeatable headers,
  JSON body, follow-redirects, file download with progress, and a status/timing/
  size/redirect summary line with color-coded status badges.
- **UI engine overhaul** (`lib/ui.sh`): panels, tables, key/value rows, gradient
  rules, multi-style spinners, animated logo reveal, `ui_ask` prompt.
- **Multi-stop gradients** (`mgradient`) and a cohesive brand palette in `lib/colors.sh`.
- **Smarter dispatcher**: animated logo, category browsing (`clixr net`), fuzzy
  "did you mean" suggestions, richer help & list with icons and counts.
- **First-run wizard** in the installer: theme picker + optional shell init.
- **Shell integration** (`clixr.sh`): `cx`/`cxl`/`cxf` aliases + bash/zsh completions.
- **Project meta**: `Makefile`, `VERSION`, `.editorconfig`, `docs/gallery.md`.

### Changed
- **Cinematic installer**: 4-phase flow (scan → deps → install → personalize),
  per-category tool counts, gradient rules, install timing, and a hero summary card.
- `curl` is now optional (not required) so minimal environments still install.
- Badges restyled to minimal glyphs (`✓ ✗ ▲ • ❯ ◦`).
- Rounded box borders by default.

### Fixed
- `ui_strip` now uses a literal ESC byte, fixing box/table alignment when content
  contains ANSI colors (affected the installer summary card and `ui_table`).
- `speed` uses portable timing (no `/usr/bin/time` dependency).
- `wipe` overwrites with `head -c` blocks instead of byte-by-byte `dd`.
- `dl` strips URL query strings from the default output filename.

## [0.1.0]

### Added
- Core dispatcher with auto plugin discovery.
- 61 tools across 7 categories (net, sec, sys, dev, web, rice, fun).
- Animated, platform-aware installer + uninstaller + self-update.
- 6 shared libraries (ui, colors, platform, utils, network, crypto).
- 8 color themes and plugin/API docs.
