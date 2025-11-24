#!/usr/bin/env python3
import socket
import time
import logging
from PIL import Image, ImageDraw, ImageFont
#from waveshare_epd import epd2in13_V4
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
    # Create image with swapped dimensions for rotation
    image = Image.new('1', (epd.height, epd.width), 255)  # Clear white
    draw = ImageDraw.Draw(image)
    
    # Try common Debian fonts in order
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
    
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (epd.height - w) // 2  # Center on wider dimension
    y = (epd.width - h) // 2   # Center on narrower dimension
    draw.text((x, y), text, font=font, fill=0)  # Black text
    
    # Rotate 90° counter-clockwise
    image = image.rotate(90, expand=True)
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
