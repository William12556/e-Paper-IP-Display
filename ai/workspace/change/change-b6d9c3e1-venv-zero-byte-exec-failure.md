Created: 2026 July 01

```yaml
# T02 Change Template v1.0 - YAML Format

change_info:
  id: "change-b6d9c3e1"
  title: "Direct module ExecStart and install.sh integrity verification"
  date: "2026-07-01"
  author: "William Watson"
  status: "implemented"
  priority: "critical"
  iteration: 2
  coupled_docs:
    issue_ref: "issue-b6d9c3e1"
    issue_iteration: 1

source:
  type: "defect_fix"
  reference: "issue-b6d9c3e1"
  description: >
    Service fails with 203/EXEC because the pip-generated console wrapper in
    the venv was truncated to zero bytes by a filesystem event. Change the
    generated systemd ExecStart to invoke the module directly, and add
    install-time verification of interpreter and entry-point integrity.

scope:
  summary: >
    In install.sh: (1) change the generated unit ExecStart from the console
    wrapper to 'venv/bin/python -m epaper_ip_display.main'; (2) add a
    verification step that the venv interpreter executes and the entry-point
    module resolves to a non-empty file; (3) point the unit's WorkingDirectory
    at /tmp instead of INSTALL_DIR, to remove INSTALL_DIR from sys.path under
    -m invocation; (4) remove legacy flat-file artefacts from INSTALL_DIR
    before venv creation.
  affected_components:
    - name: "install.sh — systemd unit heredoc"
      file_path: "install.sh"
      change_type: "modify"
    - name: "install.sh — verification"
      file_path: "install.sh"
      change_type: "modify"
    - name: "install.sh — legacy artefact cleanup"
      file_path: "install.sh"
      change_type: "add"
  affected_designs:
    - design_ref: "workspace/design/design_epaper-ip-display.md"
      sections:
        - "Deployment / systemd (pending, if approved)"
  out_of_scope:
    - "src/epaper_ip_display/main.py (unchanged; __main__ guard already present)"
    - "pyproject.toml (project.scripts entry point retained but unused by the service)"
    - "epd2in13_V4.py, epdconfig.py (source package; unrelated to the removed legacy copies)"

rational:
  problem_statement: >
    The pip-generated console script (venv/bin/epaper-ip-display) is a
    loss-prone artefact. When truncated to zero bytes, execve() returns
    ENOEXEC and systemd reports 203/EXEC, halting the service. Additionally,
    the first deployment of the -m fix (iteration 1) introduced a regression:
    WorkingDirectory=INSTALL_DIR placed INSTALL_DIR at the front of sys.path
    under -m invocation, and a legacy flat file INSTALL_DIR/epaper_ip_display.py
    (a pre-package artefact, undated Nov 2025) shadowed the installed package,
    producing 'ModuleNotFoundError: __path__ attribute not found' since a flat
    module has no __path__ for submodule resolution.
  proposed_solution: >
    Invoke the module directly. main.py contains 'if __name__ == "__main__":
    main()', so 'python -m epaper_ip_display.main' runs main(). To prevent the
    sys.path shadowing regression, WorkingDirectory is set to /tmp rather than
    removed (systemd requires a value; /tmp avoids any risk to / or
    INSTALL_DIR). The legacy flat-file artefacts are also removed from
    INSTALL_DIR by install.sh, addressing the shadowing artefact directly as
    well as the mechanism.
  alternatives_considered:
    - option: "Re-run install.sh only (rebuild venv)"
      reason_rejected: "Restores files but leaves the fragile wrapper in the execution path; does not detect recurrence"
    - option: "pip install --force-reinstall of the wrapper only"
      reason_rejected: "Same fragility; no detection"
    - option: "Remove WorkingDirectory directive entirely"
      reason_rejected: "systemd defaults to / when WorkingDirectory is unset; user declined this risk to root filesystem"
  benefits:
    - "Removes the zero-length wrapper from the execution path"
    - "Install-time detection of corrupt interpreter or empty entry-point module"
    - "Removes sys.path shadowing regression from iteration 1"
    - "Removes stray legacy artefacts from INSTALL_DIR"
  risks:
    - risk: "Install-time checks cannot prevent post-install truncation (the actual trigger for issue-b6d9c3e1)"
      mitigation: "Documented as a known limitation; durable mitigation is storage health and clean shutdowns, outside software scope"
    - risk: "Importing main at install time could trigger GPIO side effects"
      mitigation: "Verification uses importlib.util.find_spec plus file size; it locates the module without executing it"
    - risk: "Legacy artefact removal deletes files at INSTALL_DIR"
      mitigation: "Scoped to five explicitly named legacy filenames plus __pycache__; no wildcard deletion; venv/ and other content untouched"

technical_details:
  current_behavior: >
    Generated unit: ExecStart=$VENV_DIR/bin/epaper-ip-display,
    WorkingDirectory=$INSTALL_DIR.
    Verification imports epaper_ip_display and compares __version__ only.
    Legacy flat-file artefacts remain at INSTALL_DIR from prior deployment.
  proposed_behavior: >
    Generated unit: ExecStart=$VENV_DIR/bin/python -m epaper_ip_display.main,
    WorkingDirectory=/tmp. Verification additionally runs the interpreter and
    confirms the entry-point module resolves to a non-empty file. Legacy
    flat-file artefacts removed from INSTALL_DIR before venv creation.
  implementation_approach: |
    1. In the systemd heredoc, replace:
         ExecStart=$VENV_DIR/bin/epaper-ip-display
       with:
         ExecStart=$VENV_DIR/bin/python -m epaper_ip_display.main
    2. In the systemd heredoc, replace:
         WorkingDirectory=$INSTALL_DIR
       with:
         WorkingDirectory=/tmp
    3. After the existing version-verification block, add:
         - interpreter check: "$VENV_DIR/bin/python" --version
         - entry-point check: find_spec('epaper_ip_display.main') resolves and
           os.path.getsize(spec.origin) > 0
    4. Before venv creation, remove named legacy files/dirs from INSTALL_DIR
       if present: epaper_ip_display.py, epd2in13_V4.py, epdconfig.py,
       DEV_Config_64.so, sysfs_software_spi.so, __pycache__/
  code_changes:
    - component: "install.sh"
      file: "install.sh"
      change_summary: "Change generated ExecStart to module invocation; set WorkingDirectory to /tmp; add interpreter and entry-point integrity checks; add legacy artefact cleanup"
      functions_affected: []
      classes_affected: []
  data_changes: []
  interface_changes:
    - "Deployed unit must be regenerated (re-run install.sh) for ExecStart/WorkingDirectory changes to take effect"

dependencies:
  internal: []
  external:
    - library: "importlib (stdlib)"
      version_change: "none"
      impact: "none"
  required_changes:
    - "Re-run install.sh on target to regenerate the unit and rewrite venv files"

testing_requirements:
  test_approach: "Manual integration test on target hardware"
  test_cases:
    - scenario: "Reinstall via updated install.sh"
      expected_result: "Verification passes; unit ExecStart uses python -m; WorkingDirectory=/tmp; legacy artefacts removed; service active"
    - scenario: "Simulate empty entry-point module (truncate main.py) before verification"
      expected_result: "install.sh aborts with entry-point integrity error"
    - scenario: "Service start after clean reboot"
      expected_result: "Service active; display renders and updates on interface change"
    - scenario: "Legacy flat-file epaper_ip_display.py present at INSTALL_DIR before install"
      expected_result: "File removed by install.sh; service starts without ModuleNotFoundError"
  regression_scope:
    - "Polling, change detection, AP-mode line unchanged"
    - "Font size and layout unchanged"
  validation_criteria:
    - "systemctl status shows active (running), no 203/EXEC, no exit-code 1/FAILURE"
    - "journalctl shows the polling log line, not a ModuleNotFoundError"

implementation:
  effort_estimate: "< 1 hour"
  implementation_steps:
    - step: "Edit install.sh (ExecStart and verification)"
      owner: "Strategic Domain (Claude Desktop)"
    - step: "Rebuild wheel if version bump desired"
      owner: "Human"
    - step: "Reinstall on target; verify after clean reboot"
      owner: "Human"
  rollback_procedure: "Revert install.sh to prior git commit; re-run install.sh"
  deployment_notes: >
    Re-run install.sh on the Pi to rewrite the truncated venv files and
    regenerate the unit. Perform a clean reboot to confirm persistence.

verification:
  implemented_date: "2026-07-01"
  implemented_by: "Claude Desktop (Strategic Domain)"
  verification_date: ""
  verified_by: ""
  test_results: "Pending hardware verification."
  issues_found: []

traceability:
  design_updates: []
  related_changes: []
  related_issues:
    - issue_ref: "issue-b6d9c3e1"
      relationship: "source"

notes: >
  Entry point epaper_ip_display.main:main retained in pyproject.toml for manual
  use; the service no longer depends on the generated wrapper. Install-time
  checks detect corruption present at install; they do not prevent later
  filesystem truncation. Iteration 2 corrects a regression introduced by
  iteration 1 (sys.path shadowing via WorkingDirectory=INSTALL_DIR combined
  with a legacy flat-file module of the same name).

version_history:
  - version: "1.0"
    date: "2026-07-01"
    author: "William Watson"
    changes:
      - "Initial change document; install.sh edits implemented, pending hardware verification"
  - version: "1.1"
    date: "2026-07-01"
    author: "William Watson"
    changes:
      - "Iteration 2: corrected regression — WorkingDirectory changed from INSTALL_DIR to /tmp; added legacy flat-file artefact cleanup to install.sh"

metadata:
  copyright: "Copyright (c) 2025 William Watson. This work is licensed under the MIT License."
  template_version: "1.0"
  schema_type: "t02_change"
```
