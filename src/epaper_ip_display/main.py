#!/usr/bin/env python3
import socket
import time
import logging
from PIL import Image, ImageDraw, ImageFont
from . import epd2in13_V4

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

def draw_text(epd, line1, line2):
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
            font = ImageFont.truetype(font_path, 24)
            break
        except Exception:
            continue

    if font is None:
        font = ImageFont.load_default()

    bbox1 = draw.textbbox((0, 0), line1, font=font)
    w1 = bbox1[2] - bbox1[0]
    h1 = bbox1[3] - bbox1[1]
    bbox2 = draw.textbbox((0, 0), line2, font=font)
    w2 = bbox2[2] - bbox2[0]
    h2 = bbox2[3] - bbox2[1]

    gap = 4
    total_h = h1 + gap + h2
    y_start = (epd.width - total_h) // 2
    x1 = (epd.height - w1) // 2
    x2 = (epd.height - w2) // 2

    draw.text((x1, y_start), line1, font=font, fill=0)
    draw.text((x2, y_start + h1 + gap), line2, font=font, fill=0)

    image = image.rotate(90, expand=True)
    epd.display(epd.getbuffer(image))

def main():
    logging.info("Initializing e-Paper display")
    epd = epd2in13_V4.EPD()
    epd.init()
    logging.info("Clearing display")
    epd.Clear()

    hostname = socket.gethostname()
    last_ip = None

    while True:
        ip = get_ip()
        ip_text = f"IP: {ip}" if ip else "No Network"

        if ip_text != last_ip:
            logging.info(f"Updating display: {hostname} | {ip_text}")
            draw_text(epd, hostname, ip_text)
            last_ip = ip_text

        time.sleep(15)

if __name__ == '__main__':
    main()
