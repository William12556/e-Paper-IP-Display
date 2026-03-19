#!/bin/bash
# e-Paper IP Display Install Script
# Usage: ./install.sh <path-to-wheel>
# Installs to /opt/epaper-ip/, registers systemd service (Linux only)

set -e

INSTALL_DIR="/opt/epaper-ip"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_NAME="epaper-ip-display"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------
if [ -z "$1" ]; then
    echo "ERROR: Wheel path required"
    echo "Usage: ./install.sh <path-to-wheel>"
    echo "Example: ./install.sh epaper_ip_display-1.0.0-py3-none-any.whl"
    exit 1
fi

if [[ "$1" = /* ]]; then
    WHEEL_PATH="$1"
else
    WHEEL_PATH="$(pwd)/$1"
fi

if [ ! -f "$WHEEL_PATH" ]; then
    echo "ERROR: Wheel file not found: $WHEEL_PATH"
    exit 1
fi

WHEEL_FILE="$(basename "$WHEEL_PATH")"
VERSION=$(echo "$WHEEL_FILE" | cut -d'-' -f2)

echo "==> Installing epaper-ip-display version $VERSION"
echo "==> Install directory: $INSTALL_DIR"
echo "==> Wheel: $WHEEL_PATH"

# ---------------------------------------------------------------------------
# System dependencies
# ---------------------------------------------------------------------------
echo "==> Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y python3 python3-venv fonts-liberation

# ---------------------------------------------------------------------------
# Virtual environment
# ---------------------------------------------------------------------------
if [ ! -d "$VENV_DIR" ]; then
    echo "==> Creating virtual environment at $VENV_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo python3 -m venv "$VENV_DIR"
fi

# ---------------------------------------------------------------------------
# Install package
# ---------------------------------------------------------------------------
echo "==> Cleaning existing installation..."
sudo "$VENV_DIR/bin/pip" uninstall -y epaper-ip-display 2>/dev/null || true

echo "==> Installing from $WHEEL_PATH"
sudo "$VENV_DIR/bin/pip" install "$WHEEL_PATH"

# ---------------------------------------------------------------------------
# Version verification
# ---------------------------------------------------------------------------
echo "==> Verifying installation..."
INSTALLED=$(sudo "$VENV_DIR/bin/python" -c "import epaper_ip_display; print(epaper_ip_display.__version__)")

if [ "$INSTALLED" != "$VERSION" ]; then
    echo "ERROR: Version mismatch - expected $VERSION, got $INSTALLED"
    exit 1
fi

echo "Installed version: $INSTALLED"

# ---------------------------------------------------------------------------
# systemd service
# ---------------------------------------------------------------------------
echo "==> Writing systemd service file..."
sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=e-Paper IP Display Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
Environment=PYTHONUNBUFFERED=1
ExecStart=$VENV_DIR/bin/epaper-ip-display
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "==> Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

echo ""
echo "Installation successful: version $INSTALLED"
echo ""
echo "Status:  sudo systemctl status $SERVICE_NAME"
echo "Logs:    sudo journalctl -u $SERVICE_NAME -f"
