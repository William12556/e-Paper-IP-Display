# e-Paper IP Display

## Project Overview

This project implements an e-paper IP display application.

## Hardware Requirements

- Raspberry Pi (Zero or any model with 40-pin GPIO)
- Waveshare 2.13" Touch e-Paper HAT Version 4
- Required interfaces: SPI and I²C enabled

## System Requirements

- Raspberry Pi OS (Debian Bookworm or compatible)
- Python 3.9+
- System dependencies: `python3-venv`, `fonts-liberation`

## Quick Start

### 1. Hardware Setup

1. Power off the Raspberry Pi
2. Align the e-Paper HAT with the 40-pin GPIO header
3. Ensure proper pin 1 orientation
4. Reconnect power

### 2. Enable Interfaces

```bash
sudo raspi-config
# Navigate to: Interfacing Options → SPI → Enable
# Navigate to: Interfacing Options → I²C → Enable
sudo reboot
```

### 3. Installation

**Option A — curl (recommended)**

```bash
curl -fsSL https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh -o install.sh
chmod +x install.sh && ./install.sh
```

Or with wget:

```bash
wget -qO install.sh https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh
chmod +x install.sh && ./install.sh
```

**Option B — pipe to bash (no prior inspection)**

```bash
curl -fsSL https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh | bash
```

The install script handles all dependencies, creates a virtual environment at `/opt/epaper-ip/venv/`, and registers the systemd service. The service starts automatically and persists across reboots.

For development deployment or full installation options see the [Installation Guide](docs/e-Paper%20IP%20Display%20Installation%20Guide.md).

### 4. Verification

Check service status:
```bash
sudo systemctl status epaper-ip-display
sudo journalctl -u epaper-ip-display -f
```

## Operation

- Display clears on boot
- Shows hostname and current IPv4 address, or "No Network"
- Polls network status every 15 seconds
- Updates display only when IP changes
- Runs as systemd service with root privileges (required for GPIO access)

## Waveshare Resources

Download the Version 4 driver and examples:
- [Waveshare e-Paper GitHub Repository](https://github.com/waveshare/e-Paper)
- Navigate to: `RaspberryPi_JetsonNano/python/`
- Driver file: `epd2in13_V4.py`

Official product page:
- [2.13" Touch e-Paper HAT](https://www.waveshare.com/wiki/2.13inch_Touch_e-Paper_HAT)

## Troubleshooting

**Display does not refresh:**
- Verify SPI enabled: `ls -l /dev/spidev*`
- Confirm Version 4 driver in use

**Service fails to start:**
- Check service logs: `journalctl -u epaper-ip-display -n 50`
- Verify hardware access: `ls -l /dev/spidev* /dev/gpiomem`

**Touch not functional:**
- Verify I²C enabled
- Detect controller: `sudo i2cdetect -y 1`

## Documentation

Detailed guides available in `docs/`:
- [`e-Paper IP Display Installation Guide.md`](docs/e-Paper%20IP%20Display%20Installation%20Guide.md) - Full installation, update, uninstall, and troubleshooting procedures
- `Waveshare 2.13" Touch e-Paper HAT (Version 4).md` - Hardware configuration

## Project Structure

- `src/` - Python package source
- `docs/` - Technical documentation
- `tests/` - Test scripts
- `dist/` - Built wheel (generated)
- `ai/` - Governance and operational rules
- `workspace/` - Development workspace
- `deprecated/` - Superseded files

## Important Notice

**Actual fitness for purpose is not guaranteed.**

## License

MIT License

Copyright (c) 2025 William Watson
