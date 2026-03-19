# e-Paper IP Display — Tactical Domain Context

## Project

Display Raspberry Pi WiFi IPv4 address and hostname on a Waveshare 2.13" e-Paper HAT V4.
Runs as a systemd service. Polls network every 15 seconds. Updates display only on change.

## Governance

- Framework: `ai/governance.md`
- Design documents: `workspace/design/`
- Protocol compliance required. Do not create, add, remove or change source code or documents unless explicitly instructed by a T04 prompt.

## Source

- Application: `src/epaper_ip_display.py`
- Waveshare driver: `src/epd2in13_V4.py`
- Service definition: `src/epaper-ip-display.service`
- Install script: `src/epaper-ip-install.sh`

## Technology Stack

- Python 3
- PIL/Pillow — image rendering
- waveshare_epd / epd2in13_V4 — e-Paper driver (local import)
- socket — network detection
- systemd — service management
- Target platform: Raspberry Pi OS (Debian-based), aarch64

## Key Technical Facts

- Display: 122 × 250 px (physical); rendered as 250 × 122 (rotated 90° CCW)
- Font: TrueType 24pt — LiberationSans-Bold (preferred), FreeSansBold, DejaVuSans-Bold, fallback to default
- PIL API: use `textbbox()` not deprecated `textsize()`
- GPIO/SPI requires root; service runs as root
- Direct import: `import epd2in13_V4` (not waveshare_epd package)

## AEL Invocation

```bash
python ai/ael/src/orchestrator.py --mode loop --task workspace/prompt/prompt-<uuid>-<n>.md
```

## Tool Calling

Use imperative phrasing in prompts. Name MCP tools explicitly:
- `mcp-grep__grep` for search
- Filesystem MCP for file operations
