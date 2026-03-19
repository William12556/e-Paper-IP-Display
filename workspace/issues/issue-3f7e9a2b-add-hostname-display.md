Created: 2026 March 18

# Issue: Add Hostname to e-Paper Display

---

## Table of Contents

- [Issue](<#issue>)
- [Source](<#source>)
- [Affected Scope](<#affected scope>)
- [Behavior](<#behavior>)
- [Analysis](<#analysis>)
- [Resolution](<#resolution>)
- [Traceability](<#traceability>)
- [Version History](<#version history>)

---

## Issue

```yaml
issue_info:
  id: "issue-3f7e9a2b"
  title: "Add hostname display above IP address / No Network line"
  date: "2026-03-18"
  reporter: "William Watson"
  status: "open"
  severity: "low"
  type: "requirement_change"
  iteration: 1
  coupled_docs:
    change_ref: "change-3f7e9a2b"
    change_iteration: 1
```

[Return to Table of Contents](<#table of contents>)

---

## Source

```yaml
source:
  origin: "requirement_change"
  test_ref: ""
  description: >
    Human-requested addition: display the system hostname on a top line
    above the existing IP address / No Network line. Provides device
    identification on the physical display without requiring network access.
```

[Return to Table of Contents](<#table of contents>)

---

## Affected Scope

```yaml
affected_scope:
  components:
    - name: "Display Controller Module"
      file_path: "src/epaper_ip_display.py"
    - name: "Main Application Loop"
      file_path: "src/epaper_ip_display.py"
  designs:
    - design_ref: "workspace/design/design-0000-master_epaper-ip-display.md"
  version: "0.1.0"
```

[Return to Table of Contents](<#table of contents>)

---

## Behavior

```yaml
behavior:
  expected: >
    Display shows two lines:
      Line 1 (top): hostname (e.g. 'raspberrypi')
      Line 2:       'IP: 192.168.1.100' or 'No Network'
  actual: >
    Display shows one centered line:
      'IP: 192.168.1.100' or 'No Network'
  impact: "Display does not identify the device by name"
  workaround: "None"
```

[Return to Table of Contents](<#table of contents>)

---

## Analysis

```yaml
analysis:
  root_cause: >
    Hostname display not in original requirements. Requirements change
    requires addition of socket.gethostname() call and two-line layout
    in draw_text().
  technical_notes: >
    draw_text() currently renders a single centered line.
    Change requires:
      - socket.gethostname() for hostname retrieval
      - Two-line vertical layout at 24pt; lines stacked with spacing
      - Display canvas: 250 wide x 122 tall (post-rotation)
      - Both lines centered horizontally
      - Hostname retrieved in main() or draw_text(); passed as argument
  related_issues: []
```

[Return to Table of Contents](<#table of contents>)

---

## Resolution

```yaml
resolution:
  assigned_to: "Tactical Domain (AEL)"
  target_date: "2026-03-18"
  approach: "Implement via T02 change and T04 AEL prompt"
  change_ref: "change-3f7e9a2b"
  resolved_date: ""
  resolved_by: ""
  fix_description: ""
```

[Return to Table of Contents](<#table of contents>)

---

## Traceability

```yaml
traceability:
  design_refs:
    - "workspace/design/design-0000-master_epaper-ip-display.md"
  change_refs:
    - "change-3f7e9a2b"
  test_refs: []
```

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-18 | William Watson | Initial |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
