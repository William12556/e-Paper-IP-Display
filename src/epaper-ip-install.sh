#!/bin/bash
set -e

INSTALL_DIR="/opt/epaper-ip"
SERVICE_FILE="epaper-ip-display.service"
SCRIPT_FILE="epaper_ip_display.py"
DRIVER_FILE="epd2in13_V4.py"
CONFIG_FILE="epdconfig.py"

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
sudo cp "$CONFIG_FILE" "$INSTALL_DIR/"

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
