[AEL RUNTIME CONTEXT]
STATE_DIR: /Users/williamwatson/Documents/GitHub/e-Paper-IP-Display/.ael/ralph
PROJECT_ROOT: /Users/williamwatson/Documents/GitHub/e-Paper-IP-Display
[END RUNTIME CONTEXT]

Implement hostname display in src/epaper_ip_display.py.

FILE: src/epaper_ip_display.py

REQUIRED STATE — verify all of the following are present and correct.
If already correct, do not modify the file. If any item is missing or
incorrect, implement only the missing or incorrect item.

1. Import: 'import epd2in13_V4' (direct, not relative)
2. draw_text(epd, line1, line2): renders two lines, each centered
   horizontally, stacked vertically with 4px gap, using textbbox()
3. main(): calls socket.gethostname() once before the while loop
4. main(): calls draw_text(epd, hostname, ip_text) on IP state change
5. All other logic unchanged: shebang, logging, get_ip(), last_ip cache, sleep(15)

CONSTRAINTS:
- Modify only src/epaper_ip_display.py
- Do not touch epd2in13_V4.py, service file, or install script

DELIVERABLE: src/epaper_ip_display.py meeting all five criteria above.

SUCCESS: All five criteria verified; no other files changed.