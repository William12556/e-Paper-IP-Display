Created: 2026 July 01

# Issue: Service EXEC Failure (203) — Zero-Byte venv Files After Unclean Shutdown

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
- [References](<#references>)
- [Version History](<#version history>)

---

## Issue

```yaml
issue_info:
  id: "issue-b6d9c3e1"
  title: "Service EXEC failure (203) — zero-byte venv files after unclean shutdown"
  date: "2026-07-01"
  reporter: "William Watson"
  status: "closed"
  severity: "critical"
  type: "defect"
  iteration: 1
  coupled_docs:
    change_ref: "change-b6d9c3e1"
    change_iteration: 1
```

[Return to Table of Contents](<#table of contents>)

---

## Source

```yaml
source:
  origin: "monitoring"
  test_ref: ""
  description: >
    Service epaper-ip-display crash-loops with status=203/EXEC. Display
    retains a persisted frame (usb0 'no IP') and does not update when usb0
    acquires an address. Investigation on 2026-07-01 found every regular
    file in the virtual environment bin directory to be zero length.
```

[Return to Table of Contents](<#table of contents>)

---

## Affected Scope

```yaml
affected_scope:
  components:
    - name: "install.sh"
      file_path: "install.sh"
    - name: "systemd unit (generated)"
      file_path: "/etc/systemd/system/epaper-ip-display.service"
  designs:
    - design_ref: "workspace/design/design_epaper-ip-display.md"
  version: "1.1.9"
```

[Return to Table of Contents](<#table of contents>)

---

## Reproduction

```yaml
reproduction:
  prerequisites: "epaper-ip-display installed to /opt/epaper-ip via install.sh."
  steps:
    - "Observe service state: sudo systemctl status epaper-ip-display."
    - "Inspect venv bin: ls -l /opt/epaper-ip/venv/bin/."
    - "Confirm free space: df -h /opt."
  frequency: "always (once files are truncated)"
  reproducibility_conditions: >
    Occurs after files written during a venv rebuild are truncated to zero
    length by an unclean shutdown or by storage data loss. Not reproducible
    from a clean install alone; requires the truncation event.
  error_output: >
    systemctl: Process ExecStart=/opt/epaper-ip/venv/bin/epaper-ip-display
      (code=exited, status=203/EXEC); "Failed to execute ..."; "Failed at
      step EXEC spawning ...".
    ls -l /opt/epaper-ip/venv/bin/: total 0; activate, activate.csh,
      activate.fish, epaper-ip-display, pip, pip3, pip3.13 all 0 bytes;
      python -> python3 -> /usr/bin/python3 (symlinks intact).
    df -h /opt: 24G available, 15% used (disk not full).
```

[Return to Table of Contents](<#table of contents>)

---

## Behavior

```yaml
behavior:
  expected: >
    Service starts cleanly. The interpreter executes the entry point and the
    polling loop renders hostname, usb0, and wlan0 lines, updating on change.
  actual: >
    systemd cannot execute the ExecStart target. The target console script
    (/opt/epaper-ip/venv/bin/epaper-ip-display) is zero bytes, so execve()
    returns ENOEXEC and systemd reports 203/EXEC. The service crash-loops on
    RestartSec=5. No Python runs; no polling occurs. The e-Paper panel holds
    its last rendered frame because e-Paper retains an image without a driving
    process.
  impact: >
    Complete service failure. Interface state is not detected or displayed.
    Hardware is functional; the fault is loss of file contents in the venv.
  workaround: >
    Rebuild the virtual environment and reinstall, which rewrites the files:
      sudo ./install.sh <path-to-wheel>
    A clean reboot should follow to confirm persistence.
```

[Return to Table of Contents](<#table of contents>)

---

## Environment

```yaml
environment:
  python_version: "3.13"
  os: "Debian 13 (Trixie), aarch64"
  storage: "/dev/mmcblk0p2 (SD/eMMC), 29G, 15% used"
  dependencies: []
  domain: "domain_1"
```

[Return to Table of Contents](<#table of contents>)

---

## Analysis

```yaml
analysis:
  root_cause: >
    All regular files created in /opt/epaper-ip/venv/bin at 06:24 are zero
    length while their inodes, names, modes, and timestamps persist. This is
    not a packaging defect: activate and pip are written by venv and pip
    respectively, not by this project, yet are also empty. The signature is
    filesystem-level data loss of recently written files — consistent with an
    unclean shutdown on ext4 (metadata journaled, data not flushed, files
    truncated to zero on recovery) or with SD-card degradation on the
    mmcblk device. Disk space is not the cause (24G free). The observed
    203/EXEC is a downstream symptom: execve() on a zero-length file finds no
    shebang and no valid format, returns ENOEXEC, and systemd maps this to
    exit status 203/EXEC.
  technical_notes: >
    The prior verification in install.sh imports the package and compares
    __version__. That import succeeds even when the generated wrapper script
    is empty, so a corrupt or partial install can report success. The failure
    here occurred after install (on shutdown), which no install-time check can
    prevent; install-time hardening only detects corruption present at install.
  related_issues:
    - "issue-f1a3c5e7 (prior Debian 13 service crash-loop; different root cause)"
```

[Return to Table of Contents](<#table of contents>)

---

## Resolution

```yaml
resolution:
  assigned_to: "Strategic Domain"
  target_date: ""
  approach: >
    1. Immediate recovery: rebuild venv and reinstall via install.sh, which
       rewrites the zero-length files.
    2. Reduce fragile surface: change the generated systemd ExecStart from the
       pip-generated console wrapper to direct module invocation
       (venv/bin/python -m epaper_ip_display.main). The wrapper is one of the
       files lost; module invocation depends only on the interpreter symlink
       (intact) and the installed package. (change-b6d9c3e1)
    3. Harden install.sh: verify the venv interpreter runs and the entry-point
       module resolves to a non-empty file before declaring success.
    4. Out of software scope: prefer clean shutdowns; assess SD-card health
       (dmesg | grep -i 'mmc\|ext4\|I/O') to distinguish a one-off truncation
       from a failing card.
  change_ref: "change-b6d9c3e1"
  resolved_date: "2026-07-01"
  resolved_by: "William Watson"
  fix_description: >
    Confirmed on target hardware following change-b6d9c3e1 iteration 2:
    service starts under direct module invocation, no 203/EXEC, and the
    sys.path shadowing regression does not recur under
    WorkingDirectory=$INSTALL_DIR/run.
```

[Return to Table of Contents](<#table of contents>)

---

## Prevention

```yaml
prevention:
  preventive_measures: >
    Invoke the module directly from systemd rather than the generated console
    wrapper, removing one loss-prone artefact from the execution path. Verify
    interpreter and entry-point integrity at install time.
  process_improvements: >
    Add interpreter-execution and non-empty entry-point checks to install.sh
    pre-flight validation. Consider periodic clean shutdowns and storage-health
    monitoring for SD-backed deployments; these are deployment concerns, not
    software scope, and are recorded here for visibility only.
```

[Return to Table of Contents](<#table of contents>)

---

## Traceability

```yaml
traceability:
  design_refs:
    - "workspace/design/design_epaper-ip-display.md"
  change_refs:
    - "change-b6d9c3e1"
  test_refs: []
notes: >
  Root cause is storage/filesystem data loss; the code changes are mitigation
  and detection, not a cure for degrading storage.
```

[Return to Table of Contents](<#table of contents>)

---

## References

- The Linux man-pages project. execve(2) — Linux manual page. Section ERRORS (ENOEXEC).
- The systemd project. systemd.exec(5) — Process exit codes (203/EXEC).

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-07-01 | William Watson | Initial — root cause identified; fix implemented in repository, pending hardware verification |
| 1.1 | 2026-07-01 | William Watson | Noted deployment of change-b6d9c3e1 iteration 1 surfaced a regression (sys.path shadowing by a legacy flat-file module under -m invocation); corrected in change-b6d9c3e1 iteration 2. Issue remains open pending hardware verification. |
| 1.2 | 2026-07-01 | William Watson | Closed — hardware verification confirmed; no recurrence of 203/EXEC or sys.path shadowing |

---

Copyright (c) 2025 William Watson. This work is licensed under the MIT License.
