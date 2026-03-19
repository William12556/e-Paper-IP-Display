Created: 2026 March 18

# Prompt: Add Hostname Display to e-Paper

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
- [Version History](<#version history>)

---

## Prompt Info

```yaml
prompt_info:
  id: "prompt-3f7e9a2b"
  task_type: "code_generation"
  source_ref: "change-3f7e9a2b"
  date: "2026-03-18"
  priority: "low"
  iteration: 1
  coupled_docs:
    change_ref: "change-3f7e9a2b"
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
  max_iterations: 10
  boundary_conditions:
    token_budget: 50000
    time_limit_minutes: 30
```

[Return to Table of Contents](<#table of contents>)

---

## Context

```yaml
context:
  purpose: >
    Modify src/epaper_ip_display.py to display the system hostname on a
    top line above the existing IP address / No Network line on the
    Waveshare 2.13" e-Paper HAT V4.
  integration: >
    Single-file Python application running as a systemd service on
    Raspberry Pi OS (Debian, aarch64). Uses direct local import of
    epd2in13_V4 driver. PIL/Pillow for rendering.
  knowledge_references:
    - "workspace/design/design-0000-master_epaper-ip-display.md"
    - "workspace/change/change-3f7e9a2b-add-hostname-display.md"
    - "workspace/issues/issue-3f7e9a2b-add-hostname-display.md"
  constraints:
    - "Do not modify any file except src/epaper_ip_display.py"
    - "Do not change the import structure or driver files"
    - "Do not add new dependencies beyond Python standard library and existing imports"
    - "PIL API: use textbbox() not deprecated textsize()"
    - "Display physical dimensions: 122 x 250 px (rendered as 250 wide x 122 tall post-rotation)"
    - "Font size must remain 24pt"
    - "Governance: do not create, add, remove or change any documents or source code beyond the single deliverable file"
```

[Return to Table of Contents](<#table of contents>)

---

## Specification

```yaml
specification:
  description: >
    Modify draw_text() and main() in src/epaper_ip_display.py to render
    two lines: hostname (line 1) and IP address or 'No Network' (line 2).
  requirements:
    functional:
      - "draw_text(epd, line1, line2) renders line1 (top) and line2 (bottom)"
      - "Each line is centered horizontally"
      - "Both lines are vertically centered as a block on the display"
      - "Vertical gap between lines: 4 pixels"
      - "main() retrieves hostname via socket.gethostname() once before the loop"
      - "main() calls draw_text(epd, hostname, ip_text) on IP state change"
    technical:
      language: "Python"
      version: "3.x"
      standards:
        - "Use textbbox() for all text dimension calculations"
        - "Image created as Image.new('1', (epd.height, epd.width), 255) before rotation"
        - "Image rotated 90 degrees counter-clockwise before display"
        - "TrueType font 24pt with fallback chain (LiberationSans-Bold, FreeSansBold, DejaVuSans-Bold, load_default)"
        - "Black text fill=0 on white background 255"
  performance:
    - target: "No additional latency"
      metric: "Two textbbox() calls per draw; negligible overhead"
```

[Return to Table of Contents](<#table of contents>)

---

## Design

```yaml
design:
  architecture: "Modify existing single-file polling application"
  components:
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
            description: "Bottom line (IP address or 'No Network')"
        outputs:
          type: "None"
          description: "Side effect: updates physical e-Paper display"
        raises:
          - "Propagates hardware exceptions to caller"
      logic:
        - "Create image: Image.new('1', (epd.height, epd.width), 255)"
        - "Create draw context"
        - "Load font: try LiberationSans-Bold 24pt, FreeSansBold 24pt, DejaVuSans-Bold 24pt, else load_default()"
        - "bbox1 = draw.textbbox((0,0), line1, font=font)"
        - "w1 = bbox1[2]-bbox1[0]; h1 = bbox1[3]-bbox1[1]"
        - "bbox2 = draw.textbbox((0,0), line2, font=font)"
        - "w2 = bbox2[2]-bbox2[0]; h2 = bbox2[3]-bbox2[1]"
        - "gap = 4"
        - "total_h = h1 + gap + h2"
        - "y_start = (epd.width - total_h) // 2"
        - "x1 = (epd.height - w1) // 2"
        - "x2 = (epd.height - w2) // 2"
        - "draw.text((x1, y_start), line1, font=font, fill=0)"
        - "draw.text((x2, y_start + h1 + gap), line2, font=font, fill=0)"
        - "image = image.rotate(90, expand=True)"
        - "epd.display(epd.getbuffer(image))"

    - name: "main"
      type: "function"
      purpose: "Entry point — initialize display, retrieve hostname, run polling loop"
      interface:
        inputs: []
        outputs:
          type: "None"
          description: "Runs indefinitely until terminated"
        raises:
          - "Propagates initialization exceptions to systemd"
      logic:
        - "Initialize and clear e-Paper display (unchanged)"
        - "hostname = socket.gethostname()"
        - "last_ip = None"
        - "Loop: get ip, format ip_text, compare, call draw_text(epd, hostname, ip_text) on change, sleep 15"

  dependencies:
    internal: []
    external:
      - "socket (gethostname already in standard library — no new import required if socket already imported)"
      - "PIL.Image, PIL.ImageDraw, PIL.ImageFont"
      - "epd2in13_V4"
      - "time"
      - "logging"
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
    - "Overwrite src/epaper_ip_display.py with modified version"
    - "Preserve all existing imports, logging configuration, get_ip(), and service structure"
    - "Only draw_text() signature/body and main() require modification"
  files:
    - path: "src/epaper_ip_display.py"
      content: "Modified application with two-line display support"
```

[Return to Table of Contents](<#table of contents>)

---

## Success Criteria

```yaml
success_criteria:
  - "draw_text() accepts (epd, line1, line2) and renders two centered lines"
  - "main() calls socket.gethostname() and passes hostname as line1"
  - "All existing functionality preserved (polling, change detection, logging)"
  - "No new imports required beyond socket (already present)"
  - "File saved to src/epaper_ip_display.py"
  - "No other files modified"
```

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-18 | William Watson | Initial |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
