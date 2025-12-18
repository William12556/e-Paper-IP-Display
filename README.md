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
- System dependencies: `python3-pil`, `python3-spidev`, `python3-rpi.gpio`
- Font package: `fonts-liberation` (for display text rendering)

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

### 3. Install Dependencies

Install required font package:

```bash
sudo apt-get update
sudo apt-get install fonts-liberation
```

### 4. Installation

Extract the release package and run the installer:

```bash
tar xzvf epaper-ip.tar.gz
cd epaper-ip
chmod +x epaper-ip-install.sh
./epaper-ip-install.sh
```

The service starts automatically and persists across reboots.

### 5. Verification

Check service status:
```bash
sudo systemctl status epaper-ip-display.service
journalctl -u epaper-ip-display.service -f
```

## Operation

- Display clears on boot
- Shows current IPv4 address or "No Network"
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
- Check service logs: `journalctl -u epaper-ip-display.service -n 50`
- Verify hardware access: `ls -l /dev/spidev* /dev/gpiomem`

**Touch not functional:**
- Verify I²C enabled
- Detect controller: `sudo i2cdetect -y 1`

## Documentation

Detailed guides available in `docs/`:
- `e-Paper IP Display Guide.md` - Packaging and deployment
- `Waveshare 2.13" Touch e-Paper HAT (Version 4).md` - Hardware configuration

## Project Structure

- `ai/` - Governance and operational rules
- `release/` - Application releases
- `workspace/` - Development workspace
- `docs/` - Technical documentation
- `src/` - Source code

## Important Notice

**Actual fitness for purpose is not guaranteed.**

## License

MIT License - Copyright (c) 2025 William Watson
