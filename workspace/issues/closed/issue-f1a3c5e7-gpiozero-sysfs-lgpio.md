Created: 2026 March 20

# Issue: Service Crash — gpiozero sysfs Pin Factory Incompatible with Debian 13 Kernel

---

## Table of Contents

- [Issue](<#issue>)
- [Source](<#source>)
- [Affected Scope](<#affected scope>)
- [Reproduction](<#reproduction>)
- [Behavior](<#behavior>)
- [Environment](<#environment>)
- [Analysis](<#analysis>)
- [Resolution](<#resolution>)
- [Prevention](<#prevention>)
- [Traceability](<#traceability>)
- [Version History](<#version history>)

---

## Issue

```yaml
issue_info:
  id: "issue-f1a3c5e7"
  title: "Service crash — gpiozero sysfs pin factory incompatible with Debian 13 kernel"
  date: "2026-03-20"
  reporter: "William Watson"
  status: "closed"
  severity: "critical"
  type: "defect"
  iteration: 1
  coupled_docs:
    change_ref: ""
    change_iteration: null
```

[Return to Table of Contents](<#table of contents>)

---

## Source

```yaml
source:
  origin: "monitoring"
  test_ref: ""
  description: >
    Service epaper-ip-display crash-loops on Debian 13 (Trixie) at version
    1.1.1. Restart counter reached 93. Display retains last successfully
    rendered state from prior deployment; hostname feature never rendered.
    Root cause identified via journalctl traceback during post-mortem of
    AEL pipeline test on 2026-03-20.
```

[Return to Table of Contents](<#table of contents>)

---

## Affected Scope

```yaml
affected_scope:
  components:
    - name: "epdconfig"
      file_path: "src/epaper_ip_display/epdconfig.py"
    - name: "pyproject.toml"
      file_path: "pyproject.toml"
    - name: "install.sh"
      file_path: "install.sh"
  designs:
    - design_ref: "workspace/design/design-0000-master_epaper-ip-display.md"
  version: "1.1.1"
```

[Return to Table of Contents](<#table of contents>)

---

## Reproduction

```yaml
reproduction:
  prerequisites: "Debian 13 (Trixie) with kernel 6.x; epaper-ip-display v1.1.1 installed."
  steps:
    - "Install epaper-ip-display v1.1.1 via install.sh on Debian 13."
    - "Start service: sudo systemctl start epaper-ip-display."
    - "Observe crash: sudo journalctl -u epaper-ip-display -n 50."
  frequency: "always"
  reproducibility_conditions: >
    Reproducible on any Debian 13 system where lgpio is not installed and
    gpiozero defaults to the sysfs or native pin factory.
  error_output: >
    File "/opt/epaper-ip/venv/lib/python3.13/site-packages/epaper_ip_display/epdconfig.py"
      implementation = RaspberryPi()
        self.GPIO_BUSY_PIN = gpiozero.Button(self.BUSY_PIN, pull_up=False)
          self.pin.edges = 'both'
            self.factory.fs.export(self._number)
    KeyError: 24
    FileNotFoundError: [Errno 2] No such file or directory: '/sys/class/gpio/export'
```

[Return to Table of Contents](<#table of contents>)

---

## Behavior

```yaml
behavior:
  expected: >
    Service starts cleanly. epdconfig.py initialises GPIO via the lgpio
    character device interface. Display renders hostname and IP address.
  actual: >
    Service crashes at import time. epdconfig.py calls gpiozero.Button()
    during RaspberryPi() instantiation at module level. gpiozero selects
    the sysfs pin factory, which attempts to access /sys/class/gpio/export.
    This path is absent on Debian 13 kernel 6.x where the legacy sysfs GPIO
    interface is deprecated. Service crash-loops; display is not updated.
  impact: >
    Complete service failure. Hostname feature not rendered. Display frozen
    at prior state. Hardware is functional; failure is a software
    compatibility issue between gpiozero and the Debian 13 kernel.
  workaround: >
    Install lgpio manually before starting the service:
      sudo apt-get install python3-lgpio
      sudo /opt/epaper-ip/venv/bin/pip install lgpio
      sudo systemctl restart epaper-ip-display
    gpiozero auto-detects lgpio as the preferred pin factory on modern kernels.
```

[Return to Table of Contents](<#table of contents>)

---

## Environment

```yaml
environment:
  python_version: "3.13"
  os: "Debian 13 (Trixie), kernel 6.x, aarch64"
  dependencies:
    - library: "gpiozero"
      version: ">=2.0"
    - library: "lgpio"
      version: "not installed"
  domain: "domain_1"
```

[Return to Table of Contents](<#table of contents>)

---

## Analysis

```yaml
analysis:
  root_cause: >
    epdconfig.py instantiates RaspberryPi() at module import time, which
    immediately calls gpiozero.Button(). gpiozero selects its pin factory
    by probing the system at runtime. On Debian 13 with kernel 6.x, the
    legacy sysfs GPIO interface (/sys/class/gpio/) is deprecated and not
    reliably present. Without lgpio installed, gpiozero falls back to a
    factory that requires sysfs, resulting in FileNotFoundError on export.
    lgpio uses the modern character device interface (/dev/gpiochipN) which
    is present and functional on Debian 13.
  technical_notes: >
    gpiozero factory selection order (when lgpio is installed): lgpio >
    rpigpio > pigpio > native > sysfs. Installing lgpio causes gpiozero to
    select it automatically; no code change to epdconfig.py is required.
    However, lgpio must be declared as a dependency in pyproject.toml to
    ensure it is installed by install.sh via pip. The system package
    python3-lgpio may also be required for the shared library. Both
    install.sh (apt-get) and pyproject.toml (pip) must be updated.
  related_issues: []
```

[Return to Table of Contents](<#table of contents>)

---

## Resolution

```yaml
resolution:
  assigned_to: "Tactical Domain (AEL)"
  target_date: ""
  approach: >
    1. Add lgpio to pyproject.toml dependencies.
    2. Add python3-lgpio to apt-get install list in install.sh.
    3. Build new wheel; deploy via install.sh.
    No changes to epdconfig.py or application logic required.
  change_ref: ""
  resolved_date: "2026-03-20"
  resolved_by: "William Watson"
  fix_description: >
    Removed lgpio from pyproject.toml pip dependencies. Rebuilt venv with
    --system-site-packages in install.sh so python3-lgpio (apt) is visible.
    Deployed as v1.1.3. Verified on target hardware 2026-03-20.
```

[Return to Table of Contents](<#table of contents>)

---

## Prevention

```yaml
prevention:
  preventive_measures: >
    Include lgpio in pyproject.toml dependencies from initial project setup
    when targeting Debian 13 or any system with kernel 6.x+.
  process_improvements: >
    P06 §1.7.17: verify GPIO library compatibility against target OS and
    kernel version as part of pre-deployment system test. Add lgpio
    installation check to install.sh pre-flight validation.
```

[Return to Table of Contents](<#table of contents>)

---

## Traceability

```yaml
traceability:
  design_refs:
    - "workspace/design/design-0000-master_epaper-ip-display.md"
  change_refs: []
  test_refs: []
notes: >
  Discovered during post-mortem of AEL pipeline test (issue-a1c4e7f2
  cycle). Service at restart counter 93 when observed.
```

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-20 | William Watson | Initial |
| 1.1 | 2026-03-20 | William Watson | Closed — resolved via trivial change; verified on target hardware |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
