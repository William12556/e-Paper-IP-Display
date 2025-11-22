#!/usr/bin/env python3
import socket
import time
import logging
from PIL import Image, ImageDraw, ImageFont
from waveshare_epd import epd2in13_V4

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
