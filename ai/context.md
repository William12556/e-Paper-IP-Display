Created: 2026 June 17

# Project Context

---

## 1.0 Project

**Name:** e-Paper IP Display
**Description:** Shows the Raspberry Pi's WiFi IPv4 address and hostname on a Waveshare 2.13" Touch e-Paper HAT V4; runs as a systemd service, polls every 15 s and redraws only on change.

**Technology stack:** Python 3.9+ | Pillow, spidev, gpiozero, lgpio (system package `python3-lgpio`); bundled Waveshare driver `epd2in13_V4` (package-relative import)
**Target platform:** Raspberry Pi OS (Debian Bookworm or later), aarch64, SPI and I²C enabled; service runs as root

---

## 2.0 Commands

| Action | Command |
|---|---|
| Install (dev) | `pip install -e .[dev]` |
| Install (Pi) | `./bin/install.sh` (latest release), `./bin/install.sh <version>` or `./bin/install.sh <path-to-wheel>` |
| Test | `pytest tests/` (no tests exist yet) |
| Lint | n/a (none configured) |
| Build | `./bin/build.sh` |
| Release | `./bin/release.sh` (requires authenticated `gh` CLI) |

---

## 3.0 Code Style

- PEP 8
- Pillow: use `textbbox()`, not the deprecated `textsize()`
- Import the bundled driver package-relative: `from . import epd2in13_V4` (not the `waveshare_epd` package)
- Display is 122 × 250 px physical, rendered as 250 × 122 (rotated 90° CCW); font LiberationSans-Bold 24 pt with fallbacks

---

## 4.0 Repository Conventions

**Branches:** `main` only; no feature branches in use.
**Commits:** conventional commits (`feat:`, `fix:`, `docs:`, `chore:`).

---

## 5.0 Governance

| Artifact | Location |
|---|---|
| Governance | `ai/governance.md` |
| Designs | `ai/workspace/design/` |
| Changes | `ai/workspace/change/` |
| Prompts | `ai/workspace/prompt/` |
| Issues | `ai/workspace/issues/` |

---

## Version History

| Version | Date | Description |
|---|---|---|
| 0.1 | 2026-06-17 | Initial template |
| 1.0 | 2026-09-23 | Project context filled in (e-Paper IP Display) |
| 1.1 | 2026-09-23 | §1.0, §3.0: driver import corrected to package-relative |

---

Copyright (c) 2026 William Watson. MIT License.
