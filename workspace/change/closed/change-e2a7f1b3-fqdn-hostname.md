```yaml
# T02 Change Template v1.0 - YAML Format

change_info:
  id: "change-e2a7f1b3"
  title: "Change hostname display to FQDN via hostname -f"
  date: "2026-03-20"
  author: "William Watson"
  status: "verified"
  priority: "low"
  iteration: 1
  coupled_docs:
    issue_ref: "issue-e2a7f1b3"
    issue_iteration: 1

source:
  type: "enhancement"
  reference: "issue-e2a7f1b3"
  description: "Requirement g9d7e810 amended to display FQDN instead of short hostname. Implements subprocess call to hostname -f with fallback to socket.gethostname()."

scope:
  summary: "Replace socket.gethostname() with subprocess hostname -f call in main(); add subprocess import."
  affected_components:
    - name: "Main Application Loop"
      file_path: "src/epaper_ip_display/main.py"
      change_type: "modify"
  affected_designs:
    - design_ref: "workspace/design/design-0000-master_epaper-ip-display.md"
      sections:
        - "Main Application Loop — processing_logic"
        - "Design Constraints — implementation"
  out_of_scope:
    - "epd2in13_V4.py"
    - "epdconfig.py"
    - "install.sh"
    - "pyproject.toml"

rational:
  problem_statement: "Short hostname (e.g. 'raspberrypi') does not uniquely identify a device on a network with multiple Raspberry Pi hosts. FQDN (e.g. 'raspberrypi.local') resolves ambiguity via mDNS/DNS domain."
  proposed_solution: "Use subprocess.check_output(['hostname', '-f'], text=True).strip() to retrieve FQDN. Fall back to socket.gethostname() on subprocess failure to preserve resilience."
  alternatives_considered:
    - option: "socket.getfqdn()"
      reason_rejected: "May not resolve mDNS .local suffix reliably on all Debian configurations; hostname -f uses OS resolution directly"
    - option: "socket.gethostname() only"
      reason_rejected: "Does not satisfy amended requirement g9d7e810"
  benefits:
    - "Uniquely identifies device on local network"
    - "Consistent with OS 'hostname -f' output visible to sysadmins"
  risks:
    - risk: "hostname -f fails on hosts with no domain configured"
      mitigation: "Fallback to socket.gethostname() preserves current behaviour"
    - risk: "subprocess import adds a dependency"
      mitigation: "subprocess is stdlib; no external dependency added"

technical_details:
  current_behavior: "hostname = socket.gethostname() — returns short hostname"
  proposed_behavior: "hostname retrieved via subprocess(['hostname', '-f']); fallback to socket.gethostname() on exception"
  implementation_approach: |
    1. Add 'import subprocess' to imports
    2. In main(), replace:
         hostname = socket.gethostname()
       with:
         try:
             hostname = subprocess.check_output(['hostname', '-f'], text=True).strip()
         except Exception:
             hostname = socket.gethostname()
  code_changes:
    - component: "Main Application Loop"
      file: "src/epaper_ip_display/main.py"
      change_summary: "Add subprocess import; replace hostname assignment with try/except block"
      functions_affected:
        - "main"
      classes_affected: []
  data_changes: []
  interface_changes: []

dependencies:
  internal: []
  external:
    - library: "subprocess"
      version_change: "none (stdlib)"
      impact: "none"
  required_changes: []

testing_requirements:
  test_approach: "Manual integration test on target hardware"
  test_cases:
    - scenario: "hostname -f returns FQDN (e.g. raspberrypi.local)"
      expected_result: "Display line 1 shows 'raspberrypi.local'"
    - scenario: "hostname -f fails (no domain configured)"
      expected_result: "Display line 1 shows short hostname via fallback"
  regression_scope:
    - "IP address display unchanged"
    - "No Network display unchanged"
    - "15-second polling unchanged"
  validation_criteria:
    - "Line 1 output matches 'hostname -f' shell command on target"
    - "No other files modified"

implementation:
  effort_estimate: "< 1 hour"
  implementation_steps:
    - step: "AEL modifies src/epaper_ip_display/main.py"
      owner: "Tactical Domain (AEL)"
    - step: "Strategic Domain reviews generated code"
      owner: "Strategic Domain"
    - step: "Human verifies on target hardware"
      owner: "Human"
  rollback_procedure: "Revert main.py to prior git commit"
  deployment_notes: "Restart service after deployment: systemctl restart epaper-ip-display"

verification:
  implemented_date: "2026-03-20"
  implemented_by: "AEL (Devstral-Small-2-24B-Instruct-2512)"
  verification_date: "2026-03-20"
  verified_by: "William Watson"
  test_results: "Verified on target hardware (Debian 13 aarch64). FQDN displayed on line 1. Service operational."
  issues_found: []

traceability:
  design_updates:
    - design_ref: "workspace/design/design-0000-master_epaper-ip-display.md"
      sections_updated:
        - "Main Application Loop — processing_logic"
        - "Design Constraints — implementation"
      update_date: "2026-03-20"
  related_changes: []
  related_issues:
    - issue_ref: "issue-e2a7f1b3"
      relationship: "source"

notes: "AEL workflow test. Entry point verified: epaper_ip_display.main:main → src/epaper_ip_display/main.py"

version_history:
  - version: "1.0"
    date: "2026-03-20"
    author: "William Watson"
    changes:
      - "Initial change document"
  - version: "1.1"
    date: "2026-03-20"
    author: "William Watson"
    changes:
      - "Closed: status set to verified; verification fields populated; moved to closed/"

metadata:
  copyright: "Copyright (c) 2025 William Watson. This work is licensed under the MIT License."
  template_version: "1.0"
  schema_type: "t02_change"
```
