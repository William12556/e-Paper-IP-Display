Waveshare 2.13" Touch e-Paper HAT (V4) — IP Display Packaging & Deployment Guide

⸻

1. Project Structure

Create a folder named epaper-ip-package with the following files:

```text
epaper-ip-package/
├── epaper_ip_display.py          # Python script displaying the IP on e-Paper
├── epd2in13_V4.py               # Waveshare e-Paper V4 driver file
├── epaper-ip-install.sh         # Installation + service setup shell script
└── epaper-ip-display.service    # systemd service file to run the script on boot
```

⸻

2. Python Script — epaper_ip_display.py

```python
#!/usr/bin/env python3
import socket
import time
import logging
from PIL import Image, ImageDraw, ImageFont
import epd2in13_V4

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return None

def draw_text(epd, text):
    image = Image.new('1', (epd.width, epd.height), 255)  # Clear white
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()
    w, h = draw.textsize(text, font=font)
    x = (epd.width - w) // 2
    y = (epd.height - h) // 2
    draw.text((x, y), text, font=font, fill=0)  # Black text
    epd.display(epd.getbuffer(image))

def main():
    logging.info("Initializing e-Paper display")
    epd = epd2in13_V4.EPD()
    epd.init()
    logging.info("Clearing display")
    epd.Clear()

    last_ip = None

    while True:
        ip = get_ip()
        ip_text = f"IP: {ip}" if ip else "No Network"

        if ip_text != last_ip:
            logging.info(f"Updating display: {ip_text}")
            draw_text(epd, ip_text)
            last_ip = ip_text

        time.sleep(15)

if __name__ == '__main__':
    main()
```

⸻

3. Waveshare Driver File — epd2in13_V4.py
	•	Copy this file from the Waveshare e-Paper GitHub repo's RaspberryPi_JetsonNano/python folder.
	•	This is the official driver for the 2.13" V4 e-paper.
	•	Ensure it is in the same directory as your epaper_ip_display.py.

⸻

4. systemd Service File — epaper-ip-display.service

```shell
[Unit]
Description=E-Paper IP Display Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=epaper
WorkingDirectory=/opt/epaper-ip
ExecStart=/usr/bin/python3 /opt/epaper-ip/epaper_ip_display.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

The service runs under a dedicated system user 'epaper' with no shell access for security.

⸻

5. Installation Shell Script — epaper-ip-install.sh

```shell
#!/bin/bash
set -e

INSTALL_DIR="/opt/epaper-ip"
SERVICE_FILE="epaper-ip-display.service"
SCRIPT_FILE="epaper_ip_display.py"
DRIVER_FILE="epd2in13_V4.py"

echo "Installing e-Paper IP display package..."

# Create system user if doesn't exist
if ! id epaper &>/dev/null; then
    echo "Creating system user 'epaper'..."
    sudo useradd -r -s /usr/sbin/nologin -d "$INSTALL_DIR" epaper
fi

# Create directory if it doesn't exist
sudo mkdir -p "$INSTALL_DIR"

# Copy script and driver files
sudo cp "$SCRIPT_FILE" "$INSTALL_DIR/"
sudo cp "$DRIVER_FILE" "$INSTALL_DIR/"

# Copy systemd service file
cp "$SERVICE_FILE" "/etc/systemd/system/"

# Set ownership and permissions
sudo chown -R epaper:epaper "$INSTALL_DIR"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_FILE"

# Install dependencies via apt
echo "Installing Python dependencies..."
sudo apt-get update
sudo apt-get install -y python3-pil python3-pip python3-spidev python3-rpi.gpio

# Reload systemd, enable and start service
echo "Enabling and starting systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable epaper-ip-display.service
sudo systemctl restart epaper-ip-display.service

echo "Installation complete!"
echo "Check status with: sudo systemctl status epaper-ip-display.service"
```

⸻

6. Creating the Tarball

To package all the files into a tarball for easy transfer:

```shell
tar czvf epaper-ip-package.tar.gz epaper_ip_display.py epd2in13_V4.py epaper-ip-install.sh epaper-ip-display.service
```

⸻

7. Installation Instructions

After copying epaper-ip-package.tar.gz to your system, install with:

```shell
tar xzvf epaper-ip-package.tar.gz
cd epaper-ip-package
chmod +x epaper-ip-install.sh
./epaper-ip-install.sh
```

The script requires sudo privileges for system operations.

⸻

8. Manual Installation (If you want to do it step-by-step)

```shell
# Create system user
sudo useradd -r -s /usr/sbin/nologin -d /opt/epaper-ip epaper

# Install files
sudo mkdir -p /opt/epaper-ip
sudo cp epaper_ip_display.py epd2in13_V4.py /opt/epaper-ip/
sudo chown -R epaper:epaper /opt/epaper-ip
sudo cp epaper-ip-display.service /etc/systemd/system/

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable epaper-ip-display.service
sudo systemctl start epaper-ip-display.service
```

⸻

9. Checking Service Status and Logs

```shell
sudo systemctl status epaper-ip-display.service
journalctl -u epaper-ip-display.service -f
```

⸻

Notes
	•	The script clears the e-paper display on startup to avoid ghosting.
	•	The IP is updated every 15 seconds but only refreshes the display if the IP has changed.
	•	If no network connection is found, "No Network" is displayed.
	•	Make sure SPI and I2C are enabled on your system (raspi-config on Raspberry Pi OS).
	•	The service runs under a dedicated system user 'epaper' with hardware access but no shell login.
