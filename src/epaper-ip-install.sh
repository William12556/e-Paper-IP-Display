#!/bin/bash
set -e

INSTALL_DIR="/home/pi/epaper-ip"
SERVICE_FILE="epaper-ip-display.service"
SCRIPT_FILE="epaper_ip_display.py"
DRIVER_FILE="epd2in13_V4.py"

echo "Installing e-Paper IP display package..."

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy script and driver files
cp "$SCRIPT_FILE" "$INSTALL_DIR/"
cp "$DRIVER_FILE" "$INSTALL_DIR/"

# Copy systemd service file
cp "$SERVICE_FILE" "/etc/systemd/system/"

# Make Python script executable
chmod +x "$INSTALL_DIR/$SCRIPT_FILE"

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
