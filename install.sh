#!/bin/bash
# e-Paper IP Display Install Script
#
# Usage:
#   ./install.sh                              # fetch latest release from GitHub
#   ./install.sh <version>                    # fetch specific version from GitHub
#   ./install.sh <path-to-wheel>              # install from local wheel file
#
# Installs to /opt/epaper-ip/, registers systemd service.

set -e

INSTALL_DIR="/opt/epaper-ip"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_NAME="epaper-ip-display"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
GITHUB_REPO="William12556/e-Paper-IP-Display"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/releases"

# ---------------------------------------------------------------------------
# Resolve wheel: local file, specific version, or latest release
# ---------------------------------------------------------------------------
WHEEL_PATH=""

if [ -z "$1" ] || [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # No argument or version string: download from GitHub releases
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        echo "ERROR: curl or wget required for GitHub download"
        exit 1
    fi

    if [ -z "$1" ]; then
        echo "==> Fetching latest release from GitHub..."
        RELEASE_URL="${GITHUB_API}/latest"
    else
        echo "==> Fetching release $1 from GitHub..."
        RELEASE_URL="${GITHUB_API}/tags/$1"
    fi

    if command -v curl >/dev/null 2>&1; then
        RELEASE_JSON=$(curl -fsSL "$RELEASE_URL")
    else
        RELEASE_JSON=$(wget -qO- "$RELEASE_URL")
    fi

    WHEEL_URL=$(echo "$RELEASE_JSON" | grep -o '"browser_download_url": *"[^"]*\.whl"' | grep -o 'https://[^"]*')
    VERSION=$(echo "$RELEASE_JSON" | grep -o '"tag_name": *"[^"]*"' | grep -o '[0-9][^"]*')

    if [ -z "$WHEEL_URL" ]; then
        echo "ERROR: Could not find wheel asset in release"
        exit 1
    fi

    WHEEL_PATH="/tmp/epaper_ip_display-${VERSION}-py3-none-any.whl"
    echo "==> Downloading wheel: $WHEEL_URL"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$WHEEL_URL" -o "$WHEEL_PATH"
    else
        wget -qO "$WHEEL_PATH" "$WHEEL_URL"
    fi

elif [ -f "$1" ]; then
    # Local wheel file
    if [[ "$1" = /* ]]; then
        WHEEL_PATH="$1"
    else
        WHEEL_PATH="$(pwd)/$1"
    fi
    VERSION=$(basename "$WHEEL_PATH" | cut -d'-' -f2)

else
    echo "ERROR: Argument is not a file or version string: $1"
    echo "Usage: ./install.sh [version|path-to-wheel]"
    exit 1
fi

if [ ! -f "$WHEEL_PATH" ]; then
    echo "ERROR: Wheel file not found: $WHEEL_PATH"
    exit 1
fi

echo "==> Installing epaper-ip-display version $VERSION"
echo "==> Install directory: $INSTALL_DIR"

# ---------------------------------------------------------------------------
# System dependencies
# ---------------------------------------------------------------------------
echo "==> Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y python3 python3-venv fonts-liberation python3-lgpio

# ---------------------------------------------------------------------------
# Virtual environment
# ---------------------------------------------------------------------------
if [ ! -d "$VENV_DIR" ]; then
    echo "==> Creating virtual environment at $VENV_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo python3 -m venv --system-site-packages "$VENV_DIR"
else
    echo "==> Rebuilding virtual environment with --system-site-packages"
    sudo rm -rf "$VENV_DIR"
    sudo python3 -m venv --system-site-packages "$VENV_DIR"
fi

# ---------------------------------------------------------------------------
# Install package
# ---------------------------------------------------------------------------
echo "==> Cleaning existing installation..."
sudo "$VENV_DIR/bin/pip" uninstall -y epaper-ip-display 2>/dev/null || true

echo "==> Installing package..."
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
