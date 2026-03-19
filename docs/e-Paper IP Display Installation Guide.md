Created: 2026 March 19

# Waveshare 2.13" Touch e-Paper HAT (V4) — IP Display Installation Guide

## Table of Contents

- [1. Prerequisites](<#1 prerequisites>)
- [2. Initial Installation](<#2 initial installation>)
- [3. Updates](<#3 updates>)
- [4. Service Operations](<#4 service operations>)
- [5. Uninstallation](<#5 uninstallation>)
- [6. Testing](<#6 testing>)
- [7. Troubleshooting](<#7 troubleshooting>)
- [Version History](<#version history>)

---

## 1. Prerequisites

**Development machine (Mac):**
- Python 3.9+
- Build module: `pip install build`
- Project repository: `/Users/<user>/Documents/GitHub/e-Paper-IP-Display`

**Raspberry Pi:**
- Debian-based OS (tested on Debian 13 Trixie)
- Python 3.9+
- Root/sudo access
- SPI enabled (`raspi-config`)

**Verify prerequisites:**

```bash
# Mac
python3 --version   # 3.9+
python3 -m pip show build

# Pi
python3 --version   # 3.9+
```

[Return to Table of Contents](<#table of contents>)

---

## 2. Initial Installation

### 2.1. Build Package

```bash
# On Mac, in project root
cd /Users/<user>/Documents/GitHub/e-Paper-IP-Display

# Make script executable (one-time)
chmod +x build.sh

# Build distribution
./build.sh
```

The `build.sh` script:
- Verifies Python 3.9+ and build module
- Extracts version from `pyproject.toml`
- Cleans previous builds
- Creates wheel in `dist/`
- Displays transfer command

### 2.2. Transfer to Pi

```bash
# From Mac
scp dist/epaper_ip_display-*.whl pi@<hostname>:/tmp/
```

### 2.3. Install on Pi

```bash
# Connect to Pi
ssh pi@<hostname>

# Make script executable (one-time)
chmod +x install.sh

# Run install script
./install.sh /tmp/epaper_ip_display-*.whl
```

The `install.sh` script:
- Installs system dependencies (`python3-venv`, `fonts-liberation`)
- Creates virtual environment at `/opt/epaper-ip/venv/`
- Installs the wheel into the venv
- Verifies installed version
- Writes and enables the systemd service
- Starts the service

### 2.4. Verify

```bash
sudo systemctl status epaper-ip-display
sudo journalctl -u epaper-ip-display -f
```

Expected: service active, display updates with hostname and IP address.

[Return to Table of Contents](<#table of contents>)

---

## 3. Updates

### 3.1. Build New Version

Increment `version` in `pyproject.toml`, then:

```bash
# On Mac
./build.sh
```

### 3.2. Transfer and Install

```bash
# Transfer wheel
scp dist/epaper_ip_display-*.whl pi@<hostname>:/tmp/

# Connect to Pi
ssh pi@<hostname>

# Run install script
./install.sh /tmp/epaper_ip_display-*.whl
```

The install script stops the service, replaces the package, verifies version, and restarts the service.

### 3.3. Verify

```bash
sudo journalctl -u epaper-ip-display -f
```

Expected: service restarts and display resumes.

[Return to Table of Contents](<#table of contents>)

---

## 4. Service Operations

### 4.1. Control

```bash
sudo systemctl status epaper-ip-display
sudo systemctl start epaper-ip-display
sudo systemctl stop epaper-ip-display
sudo systemctl restart epaper-ip-display
sudo systemctl enable epaper-ip-display
sudo systemctl disable epaper-ip-display
```

### 4.2. Logs

```bash
# Real-time
sudo journalctl -u epaper-ip-display -f

# Recent entries
sudo journalctl -u epaper-ip-display -n 100

# Time-based
sudo journalctl -u epaper-ip-display --since "1 hour ago"
```

### 4.3. File Locations

| Path | Description |
|---|---|
| `/opt/epaper-ip/venv/` | Virtual environment |
| `/etc/systemd/system/epaper-ip-display.service` | Service file |

[Return to Table of Contents](<#table of contents>)

---

## 5. Uninstallation

```bash
sudo systemctl stop epaper-ip-display
sudo systemctl disable epaper-ip-display
sudo rm -f /etc/systemd/system/epaper-ip-display.service
sudo systemctl daemon-reload
sudo rm -rf /opt/epaper-ip
```

**Verify removal:**

```bash
sudo systemctl status epaper-ip-display  # "could not be found"
ls /opt/epaper-ip/                        # "No such file or directory"
```

[Return to Table of Contents](<#table of contents>)

---

## 6. Testing

### 6.1. Hardware Validation

```bash
# Run entry point directly
sudo /opt/epaper-ip/venv/bin/epaper-ip-display
```

Expected: display clears, shows hostname and IP address.

**Service test:**

```bash
sudo systemctl restart epaper-ip-display
sudo journalctl -u epaper-ip-display -n 50
```

**Boot persistence test:**

```bash
sudo reboot
# After reboot
sudo systemctl status epaper-ip-display
```

Expected: service starts automatically.

### 6.2. Validation Checklist

- [ ] Wheel builds without errors on Mac
- [ ] Package installs without errors on Pi
- [ ] Service active and running
- [ ] Display shows hostname and IP address
- [ ] Display updates when IP changes
- [ ] "No Network" shown when network unavailable
- [ ] Service restarts cleanly
- [ ] Boot auto-start functions

[Return to Table of Contents](<#table of contents>)

---

## 7. Troubleshooting

### 7.1. Build Failures

**Python version:**
```bash
python3 --version  # Must be 3.9+
```

**Build module missing:**
```bash
python3 -m pip install build
```

**Permission error on build.sh:**
```bash
chmod +x build.sh
```

### 7.2. Install Failures

**Version mismatch after install:**
```bash
sudo /opt/epaper-ip/venv/bin/pip install --force-reinstall /tmp/epaper_ip_display-*.whl
```

**venv creation fails:**
```bash
sudo apt-get install python3-venv
```

### 7.3. Service Will Not Start

```bash
sudo systemctl status epaper-ip-display
sudo journalctl -u epaper-ip-display -n 50
```

Common causes:
- SPI not enabled: run `raspi-config` → Interface Options → SPI
- Font missing: `sudo apt-get install fonts-liberation`
- `.so` libraries missing from package: verify `DEV_Config_64.so` and `sysfs_software_spi.so` are present in the installed package

**Locate installed package files:**
```bash
sudo /opt/epaper-ip/venv/bin/pip show -f epaper-ip-display
```

### 7.4. Display Not Updating

```bash
sudo journalctl -u epaper-ip-display | grep -i "error\|exception"
```

Common causes:
- GPIO permission denied: service must run as `root`
- Wrong `.so` architecture: `DEV_Config_64.so` required on 64-bit systems; use `DEV_Config_32.so` on 32-bit
- SPI bus not open: verify SPI is enabled and no other process holds the SPI device

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date       | Author         | Changes                                  |
| ------- | ---------- | -------------- | ---------------------------------------- |
| 1.0     | 2025-11-24 | William Watson | Initial document                         |
| 1.1     | 2026-03-19 | William Watson | Updated to current document standards    |
| 1.2     | 2026-03-19 | William Watson | Clarified project structure section      |
| 1.3     | 2026-03-19 | William Watson | Added section clarifications             |
| 1.4     | 2026-03-19 | William Watson | Renamed to Installation Guide            |
| 2.0     | 2026-03-19 | William Watson | Restructured for wheel-based deployment. |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
