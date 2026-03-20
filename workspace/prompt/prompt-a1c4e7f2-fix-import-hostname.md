Created: 2026 March 19

# Prompt: Implement Hostname Display

---

## Table of Contents

- [Prompt Info](<#prompt info>)
- [Behavioral Standards](<#behavioral standards>)
- [Tactical Execution](<#tactical execution>)
- [Context](<#context>)
- [Specification](<#specification>)
- [Design](<#design>)
- [Error Handling](<#error handling>)
- [Deliverable](<#deliverable>)
- [Success Criteria](<#success criteria>)
- [Tactical Brief](<#tactical brief>)
- [Version History](<#version history>)

---

## Prompt Info

```yaml
prompt_info:
  id: "prompt-a1c4e7f2"
  task_type: "code_generation"
  source_ref: "change-a1c4e7f2"
  date: "2026-03-19"
  priority: "low"
  iteration: 1
  coupled_docs:
    change_ref: "change-a1c4e7f2"
    change_iteration: 1
```

[Return to Table of Contents](<#table of contents>)

---

## Behavioral Standards

```yaml
behavioral_standards:
  source: "workspace/knowledge/behavioral-standards.yaml"
  enforcement_level: "advisory"
```

[Return to Table of Contents](<#table of contents>)

---

## Tactical Execution

```yaml
tactical_execution:
  mode: "ralph_loop"
  worker_model: "Devstral-Small-2-24B-Instruct-2512"
  reviewer_model: "Devstral-Small-2-24B-Instruct-2512"
  max_iterations: 5
  boundary_conditions:
    token_budget: 30000
    time_limit_minutes: 20
```

[Return to Table of Contents](<#table of contents>)

---

## Context

```yaml
context:
  purpose: >
    Implement hostname display in src/epaper_ip_display.py.
    Line 1 (top): system hostname. Line 2: IP address or 'No Network'.
    Target: Waveshare 2.13" e-Paper HAT V4 on Raspberry Pi OS (Debian, aarch64).
  integration: >
    Single-file Python application running as a systemd service.
    Driver file epd2in13_V4.py resides in src/ alongside the application.
    Direct (non-relative) import required.
  constraints:
    - "Modify only src/epaper_ip_display.py"
    - "Do not modify epd2in13_V4.py, service file, or install script"
    - "Direct import: 'import epd2in13_V4' — not 'from . import epd2in13_V4'"
    - "No new dependencies beyond Python standard library and existing imports"
    - "PIL API: use textbbox() not deprecated textsize()"
    - "Display canvas: 250 wide x 122 tall post-rotation"
    - "Font size 24pt TrueType"
    - "Governance: modify only the single deliverable file"
```

[Return to Table of Contents](<#table of contents>)

---

## Specification

```yaml
specification:
  description: >
    Produce a correct src/epaper_ip_display.py with:
      1. 'import epd2in13_V4' (not relative)
      2. draw_text(epd, line1, line2) rendering two centered lines
      3. main() retrieving hostname once before loop via socket.gethostname()
  requirements:
    functional:
      - "import epd2in13_V4 at module level (direct, not relative)"
      - "draw_text(epd, line1, line2) renders line1 top, line2 bottom"
      - "Each line centered horizontally; both lines vertically centered as block"
      - "Vertical gap between lines: 4 pixels"
      - "main() calls socket.gethostname() once before the loop; stores in hostname"
      - "main() calls draw_text(epd, hostname, ip_text) on IP state change"
      - "All other logic unchanged: get_ip(), polling, last_ip cache, sleep(15)"
    technical:
      language: "Python"
      version: "3.x"
      standards:
        - "textbbox() for all text dimension calculations"
        - "Image.new('1', (epd.height, epd.width), 255) before rotation"
        - "image.rotate(90, expand=True) before display"
        - "Font fallback chain: LiberationSans-Bold, FreeSansBold, DejaVuSans-Bold, load_default"
        - "fill=0 (black text) on white background (255)"
```

[Return to Table of Contents](<#table of contents>)

---

## Design

```yaml
design:
  architecture: "Surgical fix to single-file polling application"
  components:
    - name: "module import"
      type: "import statement"
      purpose: "Direct import of local Waveshare driver"
      logic:
        - "Replace 'from . import epd2in13_V4' with 'import epd2in13_V4'"

    - name: "draw_text"
      type: "function"
      purpose: "Render two centered lines on e-Paper display"
      interface:
        inputs:
          - name: "epd"
            type: "epd2in13_V4.EPD"
            description: "Initialized e-Paper display object"
          - name: "line1"
            type: "str"
            description: "Top line (hostname)"
          - name: "line2"
            type: "str"
            description: "Bottom line (IP address or No Network)"
        outputs:
          type: "None"
          description: "Side effect: updates physical e-Paper display"
      logic:
        - "image = Image.new('1', (epd.height, epd.width), 255)"
        - "draw = ImageDraw.Draw(image)"
        - "font fallback chain at 24pt"
        - "bbox1 = draw.textbbox((0,0), line1, font=font)"
        - "w1 = bbox1[2]-bbox1[0]; h1 = bbox1[3]-bbox1[1]"
        - "bbox2 = draw.textbbox((0,0), line2, font=font)"
        - "w2 = bbox2[2]-bbox2[0]; h2 = bbox2[3]-bbox2[1]"
        - "gap = 4; total_h = h1 + gap + h2"
        - "y_start = (epd.width - total_h) // 2"
        - "x1 = (epd.height - w1) // 2; x2 = (epd.height - w2) // 2"
        - "draw.text((x1, y_start), line1, font=font, fill=0)"
        - "draw.text((x2, y_start + h1 + gap), line2, font=font, fill=0)"
        - "image = image.rotate(90, expand=True)"
        - "epd.display(epd.getbuffer(image))"

    - name: "main"
      type: "function"
      purpose: "Entry point — initialize display, retrieve hostname, polling loop"
      logic:
        - "epd = epd2in13_V4.EPD(); epd.init(); epd.Clear()"
        - "hostname = socket.gethostname()"
        - "last_ip = None"
        - "loop: ip = get_ip(); ip_text = 'IP: <ip>' or 'No Network'"
        - "if ip_text != last_ip: draw_text(epd, hostname, ip_text); last_ip = ip_text"
        - "time.sleep(15)"

  dependencies:
    external:
      - "socket — gethostname, UDP probe"
      - "time"
      - "logging"
      - "PIL.Image, PIL.ImageDraw, PIL.ImageFont"
      - "epd2in13_V4 (direct local import)"
```

[Return to Table of Contents](<#table of contents>)

---

## Error Handling

```yaml
error_handling:
  strategy: "Propagate all exceptions to systemd for service restart"
  exceptions:
    - exception: "OSError"
      condition: "e-Paper hardware communication failure"
      handling: "Propagate — systemd restarts service"
    - exception: "Exception"
      condition: "Font loading failure"
      handling: "Fallback chain; final fallback to ImageFont.load_default()"
  logging:
    level: "INFO"
    format: "%(asctime)s [%(levelname)s] %(message)s"
```

[Return to Table of Contents](<#table of contents>)

---

## Deliverable

```yaml
deliverable:
  format_requirements:
    - "Overwrite src/epaper_ip_display.py with corrected version"
    - "Preserve shebang line, logging config, get_ip() unchanged"
    - "Only import statement, draw_text(), and main() require change"
  files:
    - path: "src/epaper_ip_display.py"
      content: "Corrected application with direct import and two-line display"
```

[Return to Table of Contents](<#table of contents>)

---

## Success Criteria

```yaml
success_criteria:
  - "Line 1 of source: '#!/usr/bin/env python3'"
  - "Import statement: 'import epd2in13_V4' (no dot prefix)"
  - "draw_text signature: draw_text(epd, line1, line2)"
  - "main() contains 'hostname = socket.gethostname()' before while loop"
  - "main() calls draw_text(epd, hostname, ip_text)"
  - "All other logic (get_ip, last_ip cache, sleep) preserved"
  - "No other files modified"
```

[Return to Table of Contents](<#table of contents>)

---

## Tactical Brief

```yaml
tactical_brief: |
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
```

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-19 | William Watson | Initial — fixes broken relative import from prior AEL run (prompt-3f7e9a2b) |
| 1.1 | 2026-03-20 | William Watson | Revised for fresh AEL run: removed bug-description framing; replaced with verify-then-implement pattern to prevent model from introducing then fixing non-existent bug |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
