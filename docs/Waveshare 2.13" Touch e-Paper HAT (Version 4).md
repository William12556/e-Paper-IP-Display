# Waveshare 2.13" Touch e-Paper HAT (Version 4)

## Installation and Configuration Guide (GitHub Repository Method)

This guide provides a structured, step-by-step procedure for installing and configuring the Waveshare 2.13" Touch e-Paper HAT (V4) on a Raspberry Pi Zero (or any Raspberry Pi using Debian/Pi OS Bookworm). It assumes the GitHub repository clone workflow.

---

## 1. Hardware Installation

1. Power off the Raspberry Pi and disconnect the power supply.
2. Align the Waveshare 2.13" Touch e-Paper HAT (V4) with the 40‑pin GPIO header. Ensure pin 1 orientation is correct and the board is fully seated.
3. If the display is connected via a ribbon cable or ZIF connector, ensure that the locking tab is opened, the cable is inserted fully, and the tab is locked again.
4. Reconnect power and boot the device.

---

## 2. Enable Required Interfaces (SPI and I²C)

The e‑Paper display uses SPI; the touch controller communicates over I²C.

### Enable using raspi-config

```bash
sudo raspi-config
```

Navigate to:

* *Interfacing Options → SPI → Enable*
* *Interfacing Options → I2C → Enable*

Reboot when prompted:

```bash
sudo reboot
```

### Post‑reboot Validation

Check that SPI devices exist:

```bash
ls -l /dev/spidev*
```

Check the I²C bus and detect the touch controller:

```bash
sudo apt install -y i2c-tools
sudo i2cdetect -y 1
```

---

## 3. Install System Dependencies

These packages are required for Python, SPI access, GPIO control, and image rendering.

```bash
sudo apt update
sudo apt install -y \
    git \
    python3-pil \
    python3-numpy \
    python3-rpi.gpio \
    python3-spidev \
    python3-venv \
    python3-full
```

---

## 4. Clone the Waveshare e-Paper Repository

Clone the official Waveshare e‑Paper driver repository:

```bash
cd ~
git clone https://github.com/waveshare/e-Paper.git
```

Navigate to the Python driver directory:

```bash
cd e-Paper/RaspberryPi_JetsonNano/python
```

This directory contains all e‑Paper models and example scripts.

---

## 5. Identify the Version 4 Driver

The Version 4 2.13" Touch e‑Paper typically includes one of the following directories:

* `epd2in13_V4` or similar
* A driver file such as `epd2in13_V4.py`
* A demo script referencing the V4 driver

Confirm by listing contents:

```bash
ls -1
```

Look for:

* `epd2in13_V4.py`
* `epd2in13_V4/`
* A corresponding demo file in `examples/`

---

## 6. Running the Demo Script

Once you identify the correct driver or example:

```bash
python3 <demo_filename.py>
```

Common examples (names differ by repo revision):

* `epd_2in13_V4_test.py`
* `Touch_ePaper_2in13_V4_test.py`

Successful execution will clear the display and draw test patterns or text.

---

## 7. Permissions and User Groups

To run e‑Paper scripts without root permissions, ensure the user is in the correct groups:

```bash
groups
```

If `spi`, `i2c`, or `gpio` are missing, add them:

```bash
sudo usermod -aG spi,i2c,gpio <username>
```

Log out and back in for the group membership to apply.

---

## 8. Deploying Your Own Script (Example: IP Display)

1. Create a working directory, e.g.:

```bash
mkdir -p ~/epaper-ip
```

2. Copy or create your custom Python script inside this directory.
3. Import the driver module from the cloned repository or copy the `epd2in13_V4.py` driver locally to keep the deployment self-contained.

---

## 9. (Optional) Running via systemd at Boot

Create a service file:

```
[Unit]
Description=E-Paper IP Display
After=network-online.target

[Service]
User=<username>
WorkingDirectory=/home/<username>/epaper-ip
ExecStart=/usr/bin/python3 /home/<username>/epaper-ip/ip_display.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Install and enable the service:

```bash
sudo cp ip-display.service /etc/systemd/system/
sudo systemctl enable ip-display.service
sudo systemctl start ip-display.service
```

---

## 10. Troubleshooting

### Display does not refresh

* Verify SPI is enabled.
* Check `/dev/spidev0.0` exists.
* Confirm correct versioned driver (`V4`) is used.

### Touch does not work

* Confirm I²C is enabled.
* Run `i2cdetect -y 1` to verify that the touch controller appears.
* Ensure the ribbon cable is fully inserted and locked.

### Python driver import errors

* Ensure you are running the script from the directory containing the driver, or adjust `PYTHONPATH`.

---

## 11. Summary

By following this guide, the Waveshare 2.13" Touch e-Paper HAT (V4) can be installed, validated, and configured reliably using the Waveshare GitHub repository. Once drivers and interfaces are confirmed, custom scripts (such as displaying the system IP address) can be deployed and optionally executed automatically at boot.

---

End of document.
