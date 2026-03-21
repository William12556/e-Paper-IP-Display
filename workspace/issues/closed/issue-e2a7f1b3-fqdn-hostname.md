```yaml
# T03 Issue Template v1.0 - YAML Format

issue_info:
  id: "issue-e2a7f1b3"
  title: "Change hostname display to FQDN via hostname -f"
  date: "2026-03-20"
  reporter: "William Watson"
  status: "closed"
  severity: "low"
  type: "requirement_change"
  iteration: 1
  coupled_docs:
    change_ref: "change-e2a7f1b3"
    change_iteration: 1

source:
  origin: "requirement_change"
  test_ref: ""
  description: "Requirement g9d7e810 amended: display line 1 must show FQDN (hostname -f) rather than short hostname (socket.gethostname()). Rationale: devices sharing a short hostname are indistinguishable; FQDN (e.g. raspberrypi.local) resolves ambiguity."

affected_scope:
  components:
    - name: "Main Application Loop"
      file_path: "src/epaper_ip_display/main.py"
  designs:
    - design_ref: "workspace/design/design-0000-master_epaper-ip-display.md"
  version: "1.1.3"

reproduction:
  prerequisites: "Deployed service displaying short hostname"
  steps:
    - "Observe line 1 of display shows short hostname only (e.g. 'raspberrypi')"
  frequency: "always"
  reproducibility_conditions: "Any host with a configured domain suffix (mDNS .local, DNS domain)"
  preconditions: ""
  test_data: ""
  error_output: ""

behavior:
  expected: "Line 1 shows FQDN (e.g. 'raspberrypi.local') retrieved via subprocess call to 'hostname -f'"
  actual: "Line 1 shows short hostname (e.g. 'raspberrypi') retrieved via socket.gethostname()"
  impact: "Device not uniquely identifiable when multiple devices share a short hostname"
  workaround: "None"

environment:
  python_version: "3.x"
  os: "Debian 13 (Trixie) aarch64"
  dependencies:
    - library: "subprocess"
      version: "stdlib"

analysis:
  root_cause: "Requirement g9d7e810 originally specified socket.gethostname(); amended to require FQDN"
  technical_notes: "subprocess.check_output(['hostname', '-f'], text=True).strip() returns FQDN on Linux. Fallback to socket.gethostname() required on failure. Import subprocess must be added."
  related_issues: []

resolution:
  assigned_to: "AEL"
  target_date: "2026-03-20"
  approach: "Add subprocess import; replace hostname = socket.gethostname() with try/except block calling hostname -f"
  change_ref: "change-e2a7f1b3"
  resolved_date: "2026-03-20"
  resolved_by: "William Watson"
  fix_description: "Added import subprocess; replaced hostname assignment in main() with try/except block using subprocess.check_output(['hostname', '-f'], text=True).strip() with fallback to socket.gethostname()"

verification:
  verified_date: "2026-03-20"
  verified_by: "William Watson"
  test_results: "Verified on target hardware (Debian 13 aarch64). Display line 1 shows FQDN. Service operational."
  closure_notes: "Human accepted. Closed per P00 §1.1.14."

prevention:
  preventive_measures: "Verify requirements against FQDN vs short hostname semantics at elicitation stage"
  process_improvements: ""

verification_enhanced:
  verification_steps:
    - "On target hardware, confirm line 1 shows FQDN matching 'hostname -f' output"
    - "Confirm fallback to short hostname when hostname -f fails"
  verification_results: "Line 1 shows FQDN on target hardware. Test passed."

traceability:
  design_refs:
    - "workspace/design/design-0000-master_epaper-ip-display.md"
  change_refs:
    - "change-e2a7f1b3"
  test_refs: []

notes: "AEL workflow test. UUID e2a7f1b3 propagates through issue, change, prompt."

loop_context:
  was_loop_execution: false
  blocked_at_iteration: 0
  failure_mode: ""
  last_review_feedback: ""

version_history:
  - version: "1.0"
    date: "2026-03-20"
    author: "William Watson"
    changes:
      - "Initial issue document"
  - version: "1.1"
    date: "2026-03-20"
    author: "William Watson"
    changes:
      - "Closed: resolution and verification fields populated; moved to closed/"

metadata:
  copyright: "Copyright (c) 2025 William Watson. This work is licensed under the MIT License."
  template_version: "1.0"
  schema_type: "t03_issue"
```
