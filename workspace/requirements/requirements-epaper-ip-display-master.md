Created: 2026 March 18

# Requirements: e-Paper IP Display

---

## Table of Contents

- [Project Information](<#project information>)
- [Naming Conventions](<#naming conventions>)
- [Functional Requirements](<#functional requirements>)
- [Non-Functional Requirements](<#non-functional requirements>)
- [Architectural Requirements](<#architectural requirements>)
- [Traceability](<#traceability>)
- [Validation](<#validation>)
- [Version History](<#version history>)

---

## Project Information

```yaml
project_info:
  name: "e-Paper IP Display"
  version: "0.1.0"
  date: "2026-03-18"
  author: "William Watson"
  status: "active"
  note: "Reverse-engineered from src/epaper_ip_display.py v0.1.0"
```

[Return to Table of Contents](<#table of contents>)

---

## Naming Conventions

```yaml
naming_conventions:
  package_name: "epaper_ip_display"
  module_style: "snake_case"
  class_style: "PascalCase"
  function_style: "snake_case"
  constant_style: "UPPER_SNAKE_CASE"
  notes: "Single-module application; no package structure required"
```

[Return to Table of Contents](<#table of contents>)

---

## Functional Requirements

```yaml
functional_requirements:

  - id: "a3f1b200"
    type: "functional"
    description: "Display WiFi IPv4 address on e-Paper screen"
    acceptance_criteria:
      - "IP address rendered as 'IP: <address>' on display"
      - "Address obtained via socket UDP probe to 8.8.8.8:80"
    source: "source code"
    rationale: "Core purpose of the application"
    dependencies: []

  - id: "b4c2d300"
    type: "functional"
    description: "Display 'No Network' when WiFi is unavailable"
    acceptance_criteria:
      - "Display shows 'No Network' when socket probe fails"
      - "Transitions back to IP display when network restored"
    source: "source code"
    rationale: "Graceful degradation for disconnected state"
    dependencies: ["a3f1b200"]

  - id: "c5e3f400"
    type: "functional"
    description: "Poll network status every 15 seconds"
    acceptance_criteria:
      - "time.sleep(15) enforced between each poll cycle"
    source: "source code"
    rationale: "Balances responsiveness with e-Paper wear"
    dependencies: ["a3f1b200"]

  - id: "d6a4b500"
    type: "functional"
    description: "Update display only when IP state changes"
    acceptance_criteria:
      - "last_ip cache compared before triggering display refresh"
      - "No display update when IP is unchanged"
    source: "source code"
    rationale: "Minimises e-Paper refresh cycles"
    dependencies: ["a3f1b200", "c5e3f400"]

  - id: "e7b5c600"
    type: "functional"
    description: "Run as systemd service with automatic start on boot"
    acceptance_criteria:
      - "Service enabled via systemctl enable"
      - "Service starts on boot without manual intervention"
    source: "source code"
    rationale: "Headless deployment requirement"
    dependencies: []

  - id: "g9d7e810"
    type: "functional"
    description: "Display hostname on top line above IP address / No Network"
    acceptance_criteria:
      - "System hostname rendered as first line via socket.gethostname()"
      - "Hostname line appears above IP address or No Network line"
      - "Both lines centered horizontally on display"
    source: "requirement_change"
    rationale: "Device identification without network access"
    dependencies: ["a3f1b200"]

  - id: "f8c6d700"
    type: "functional"
    description: "Automated installation via shell script"
    acceptance_criteria:
      - "epaper-ip-install.sh installs all dependencies and configures service"
      - "Script enables and starts service on completion"
    source: "source code"
    rationale: "Repeatable deployment"
    dependencies: ["e7b5c600"]
```

[Return to Table of Contents](<#table of contents>)

---

## Non-Functional Requirements

```yaml
non_functional_requirements:

  - id: "nf1a2b30"
    type: "non_functional"
    category: "reliability"
    description: "Service restarts automatically on failure"
    acceptance_criteria:
      - "systemd Restart=always configured"
      - "RestartSec=5 delay between restarts"
    target_metric: "Recovery within 10 seconds of failure"
    source: "source code"
    rationale: "Unattended operation requirement"
    dependencies: ["e7b5c600"]

  - id: "nf2c3d40"
    type: "non_functional"
    category: "performance"
    description: "Display refresh occurs only on state change"
    acceptance_criteria:
      - "No unnecessary e-Paper refresh cycles"
    target_metric: "Zero redundant refreshes per polling cycle"
    source: "source code"
    rationale: "e-Paper wear reduction"
    dependencies: ["d6a4b500"]

  - id: "nf3e4f50"
    type: "non_functional"
    category: "maintainability"
    description: "Single-file application structure"
    acceptance_criteria:
      - "All application logic in src/epaper_ip_display.py"
      - "Waveshare driver isolated in src/epd2in13_V4.py"
    target_metric: "n/a"
    source: "source code"
    rationale: "Simplicity; minimal deployment footprint"
    dependencies: []
```

[Return to Table of Contents](<#table of contents>)

---

## Architectural Requirements

```yaml
architectural_requirements:

  - id: "ar1f2a30"
    type: "architectural"
    description: "Python 3 on Raspberry Pi OS (Debian-based Linux)"
    acceptance_criteria:
      - "Application executes under Python 3"
      - "Compatible with aarch64 Debian"
    constraints:
      - "No Python 2 compatibility required"
    source: "source code"
    rationale: "Target deployment platform"
    dependencies: []

  - id: "ar2b3c40"
    type: "architectural"
    description: "Waveshare epd2in13_V4 driver via direct local import"
    acceptance_criteria:
      - "'import epd2in13_V4' used (not waveshare_epd package)"
      - "Driver file present in src/"
    constraints:
      - "SPI interface must be enabled on Raspberry Pi"
    source: "source code"
    rationale: "Driver packaging not available via pip on target platform"
    dependencies: ["ar1f2a30"]

  - id: "ar3d4e50"
    type: "architectural"
    description: "Service runs as root for GPIO/SPI access"
    acceptance_criteria:
      - "systemd service unit has no User= restriction (defaults to root)"
    constraints:
      - "GPIO access requires root on modern Debian"
    source: "source code"
    rationale: "Hardware access requirement"
    dependencies: ["e7b5c600"]

  - id: "ar4f5a60"
    type: "architectural"
    description: "PIL/Pillow used for image rendering with textbbox() API"
    acceptance_criteria:
      - "textbbox() used for text dimension calculation (not deprecated textsize())"
      - "Image rendered at (epd.height, epd.width) then rotated 90° CCW"
    constraints:
      - "fonts-liberation package required for TrueType font paths"
    source: "source code"
    rationale: "Display requires image buffer; textsize() deprecated in Pillow 10+"
    dependencies: ["ar1f2a30"]

  - id: "ar5b6c70"
    type: "architectural"
    description: "Text rendered at 24pt TrueType with 90° CCW rotation"
    acceptance_criteria:
      - "Font size 24pt; LiberationSans-Bold preferred"
      - "Image rotated 90° counter-clockwise before display"
    constraints:
      - "Display physical dimensions: 122 × 250 px"
    source: "source code"
    rationale: "Legibility and orientation of HAT on device"
    dependencies: ["ar4f5a60"]
```

[Return to Table of Contents](<#table of contents>)

---

## Traceability

```yaml
traceability:
  design_refs:
    - req_id: "a3f1b200"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "IP Detection Module"
    - req_id: "b4c2d300"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "IP Detection Module"
    - req_id: "c5e3f400"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "Main Application Loop"
    - req_id: "d6a4b500"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "Main Application Loop"
    - req_id: "e7b5c600"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "Installation Framework"
    - req_id: "g9d7e810"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "Display Controller Module"
    - req_id: "f8c6d700"
      design_doc: "workspace/design/design-0000-master_epaper-ip-display.md"
      design_section: "Installation Framework"
  code_refs:
    - req_id: "a3f1b200"
      component: "get_ip"
      file_path: "src/epaper_ip_display.py"
    - req_id: "b4c2d300"
      component: "get_ip"
      file_path: "src/epaper_ip_display.py"
    - req_id: "c5e3f400"
      component: "main"
      file_path: "src/epaper_ip_display.py"
    - req_id: "d6a4b500"
      component: "main"
      file_path: "src/epaper_ip_display.py"
    - req_id: "e7b5c600"
      component: "epaper-ip-display.service"
      file_path: "src/epaper-ip-display.service"
    - req_id: "g9d7e810"
      component: "draw_text"
      file_path: "src/epaper_ip_display.py"
    - req_id: "f8c6d700"
      component: "epaper-ip-install.sh"
      file_path: "src/epaper-ip-install.sh"
    - req_id: "ar4f5a60"
      component: "draw_text"
      file_path: "src/epaper_ip_display.py"
    - req_id: "ar5b6c70"
      component: "draw_text"
      file_path: "src/epaper_ip_display.py"
```

[Return to Table of Contents](<#table of contents>)

---

## Validation

```yaml
validation:
  completeness_check: "Requirements cover all observable behaviours in src/epaper_ip_display.py v0.1.0 plus requirement change g9d7e810"
  clarity_check: "All requirements have objective acceptance criteria"
  testability_check: "All requirements verifiable on target hardware or via inspection"
  conflicts_identified: []
```

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-18 | William Watson | Initial — reverse-engineered from src/epaper_ip_display.py v0.1.0 |
| 1.1 | 2026-03-19 | William Watson | Added requirement g9d7e810: hostname display above IP/No Network line |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
