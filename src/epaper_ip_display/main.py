#!/usr/bin/env python3
import json
import socket
import subprocess
import time
import logging
from PIL import Image, ImageDraw, ImageFont
from . import epd2in13_V4

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

PI_NETCONFIG_AP_IP = "192.168.50.1"

def get_interface_ip(interface):
    """Return the first IPv4 address of the named interface, or None."""
    try:
        output = subprocess.check_output(['ip', '-j', 'addr', 'show'], text=True)
        interfaces = json.loads(output)
    except Exception:
        return None

    for iface in interfaces:
        if iface.get('ifname') != interface:
            continue
        for addr in iface.get('addr_info', []):
            if addr.get('family') == 'inet':
                return addr.get('local')
    return None

def draw_text(epd, lines):
    image = Image.new('1', (epd.height, epd.width), 255)
    draw = ImageDraw.Draw(image)

    font_paths = [
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]

    font = None
    for font_path in font_paths:
        try:
            font = ImageFont.truetype(font_path, 20)
            break
        except Exception:
            continue

    if font is None:
        font = ImageFont.load_default()

    gap = 4
    metrics = []
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        metrics.append((w, h))

    total_h = sum(h for _, h in metrics) + gap * (len(lines) - 1)
    y = (epd.width - total_h) // 2

    for line, (w, h) in zip(lines, metrics):
        x = (epd.height - w) // 2
        draw.text((x, y), line, font=font, fill=0)
        y += h + gap

    image = image.rotate(90, expand=True)
    epd.display(epd.getbuffer(image))

def main():
    logging.info("Initializing e-Paper display")
    epd = epd2in13_V4.EPD()
    epd.init()
    logging.info("Clearing display")
    epd.Clear()

    try:
        hostname = subprocess.check_output(['hostname', '-f'], text=True).strip()
    except Exception:
        hostname = socket.gethostname()
    last_state = None

    while True:
        usb_ip = get_interface_ip('usb0')
        wlan_ip = get_interface_ip('wlan0')
        usb_text = f"usb0: {usb_ip}" if usb_ip else "usb0: no IP"
        wlan_text = f"wlan0: {wlan_ip}" if wlan_ip else "wlan0: no IP"
        ap_active = (wlan_ip == PI_NETCONFIG_AP_IP)
        state = (usb_text, wlan_text, ap_active)

        if state != last_state:
            lines = [hostname, usb_text, wlan_text]
            if ap_active:
                lines.append("AP mode active")
            logging.info(f"Updating display: {hostname} | {usb_text} | {wlan_text} | AP active: {ap_active}")
            draw_text(epd, lines)
            last_state = state

        time.sleep(15)

if __name__ == '__main__':
    main()
