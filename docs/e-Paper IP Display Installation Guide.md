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
- Project repository cloned locally
- `gh` CLI for release publishing: `brew install gh`, then `gh auth login`

**Raspberry Pi:**
- Debian-based OS (tested on Debian 13 Trixie)
- Python 3.9+
- Root/sudo access
- SPI enabled (`raspi-config` → Interface Options → SPI)

**Verify prerequisites:**

```bash
# Mac
python3 --version        # 3.9+
python3 -m pip show build
gh --version             # required for release.sh only

# Pi
python3 --version        # 3.9+
```

[Return to Table of Contents](<#table of contents>)

---

## 2. Initial Installation

Two workflows are provided: one for development and one for general deployment.

---

### Development Deployment

For use during development and testing. The wheel is built locally and transferred directly to the Pi via SCP. No GitHub release is created.

**Step 1 — Build (Mac)**

```bash
cd /Users/<user>/Documents/GitHub/e-Paper-IP-Display

# One-time
chmod +x build.sh install.sh

./build.sh
```

`build.sh` verifies prerequisites, builds the wheel into `dist/`, and prints next-step commands.

**Step 2 — Transfer and install**

```bash
# Transfer wheel and install script in one command
scp dist/epaper_ip_display-*.whl install.sh pi@<hostname>:/tmp/

# Install on Pi
ssh pi@<hostname>
chmod +x /tmp/install.sh && /tmp/install.sh /tmp/epaper_ip_display-*.whl
```

---

### General Deployment

For publishing a release to GitHub. `release.sh` calls `build.sh`, then publishes a tagged GitHub release with the wheel and `install.sh` as downloadable assets.

**Step 1 — Build and publish (Mac)**

```bash
chmod +x release.sh
./release.sh
```

On completion, `release.sh` prints the install command for the Pi.

**Step 2 — Install on Pi**

Three options are available.

**Option A — curl (recommended)**

Fetches `install.sh` from the latest release. `install.sh` downloads the wheel automatically.

```bash
curl -fsSL https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh -o install.sh
chmod +x install.sh && ./install.sh
```

Or with wget:

```bash
wget -qO install.sh https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh
chmod +x install.sh && ./install.sh
```

To install a specific version:

```bash
./install.sh 1.0.0
```

**Option B — pipe to bash**

Minimal keystrokes. Note: the script executes without prior inspection.

```bash
curl -fsSL https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh | bash
```

---

`install.sh` (all options):
- Installs system dependencies (`python3-venv`, `fonts-liberation`)
- Creates virtual environment at `/opt/epaper-ip/venv/`
- Installs the wheel
- Verifies installed version
- Writes and enables the systemd service
- Starts the service

### 2.3. Verify

```bash
sudo systemctl status epaper-ip-display
sudo journalctl -u epaper-ip-display -f
```

Expected: service active, display shows hostname and IP address.

[Return to Table of Contents](<#table of contents>)

---

## 3. Updates

Increment `version` in `pyproject.toml`, then follow the same workflow used for initial installation.

**Development deployment:**

```bash
# Mac
./build.sh
scp dist/epaper_ip_display-*.whl install.sh pi@<hostname>:/tmp/

# Pi
/tmp/install.sh /tmp/epaper_ip_display-*.whl
```

**General deployment:**

```bash
# Mac
./release.sh

# Pi — Option A
./install.sh

# Pi — Option B
curl -fsSL https://github.com/William12556/e-Paper-IP-Display/releases/latest/download/install.sh | bash
```

The install script stops the running service, replaces the package, verifies the version, and restarts the service.

### 3.1. Verify

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
| 2.1     | 2026-03-19 | William Watson | Added GitHub release workflow; three install options (GitHub download, SCP, pipe-to-bash); release.sh |
| 2.2     | 2026-03-19 | William Watson | Distinguished development and general deployment workflows; surfaced release.sh in build/release section |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
