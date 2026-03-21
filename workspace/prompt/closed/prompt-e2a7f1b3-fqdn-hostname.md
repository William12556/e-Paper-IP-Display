```yaml
# T04 Prompt Template v1.0 - YAML Format

prompt_info:
  id: "prompt-e2a7f1b3"
  task_type: "code_generation"
  source_ref: "change-e2a7f1b3"
  date: "2026-03-20"
  priority: "low"
  iteration: 1
  coupled_docs:
    change_ref: "change-e2a7f1b3"
    change_iteration: 1

behavioral_standards:
  source: "workspace/knowledge/behavioral-standards.yaml"
  enforcement_level: "advisory"

tactical_execution:
  mode: "ralph_loop"
  worker_model: "Devstral-Small-2-24B-Instruct-2512"
  reviewer_model: "Devstral-Small-2-24B-Instruct-2512"
  max_iterations: 5
  boundary_conditions:
    token_budget: 50000
    time_limit_minutes: 15

context:
  purpose: "Change hostname retrieval in main() from socket.gethostname() to FQDN via subprocess hostname -f"
  integration: "Single-module systemd service; entry point epaper_ip_display.main:main"
  knowledge_references: []
  constraints:
    - "Modify only src/epaper_ip_display/main.py"
    - "Do not change any other file"
    - "subprocess is stdlib; no pyproject.toml changes required"

specification:
  description: "Replace socket.gethostname() with subprocess.check_output(['hostname', '-f']) in main(). Add import subprocess. Wrap in try/except with socket.gethostname() fallback."
  requirements:
    functional:
      - "Add 'import subprocess' to module-level imports"
      - "In main(), replace 'hostname = socket.gethostname()' with try/except block: try subprocess call, except fall back to socket.gethostname()"
      - "All other logic unchanged"
    technical:
      language: "Python"
      version: "3.x"
      standards:
        - "subprocess.check_output(['hostname', '-f'], text=True).strip()"
        - "Fallback: socket.gethostname()"

design:
  architecture: "Single function patch in main()"
  components:
    - name: "main"
      type: "function"
      purpose: "Retrieve FQDN before polling loop"
      interface:
        inputs: []
        outputs:
          type: "None"
          description: "Side effect: display updated continuously"
        raises: []
      logic:
        - "Add import subprocess at top of file"
        - "Replace: hostname = socket.gethostname()"
        - "With:"
        - "  try:"
        - "      hostname = subprocess.check_output(['hostname', '-f'], text=True).strip()"
        - "  except Exception:"
        - "      hostname = socket.gethostname()"
  dependencies:
    internal: []
    external:
      - "subprocess (stdlib)"

deliverable:
  format_requirements:
    - "Save generated code directly to specified path"
  files:
    - path: "src/epaper_ip_display/main.py"
      content: "Modified file with subprocess import and FQDN hostname retrieval"

success_criteria:
  - "import subprocess present at module level"
  - "main() contains try/except block calling subprocess.check_output(['hostname', '-f'], text=True).strip()"
  - "Fallback to socket.gethostname() in except clause"
  - "No other files modified"
  - "All existing logic (shebang, logging, get_ip, draw_text, last_ip, sleep) preserved"

element_registry:
  source: ""
  entries:
    modules:
      - name: "main"
        path: "src/epaper_ip_display/main.py"
    functions:
      - name: "main"
        module: "epaper_ip_display.main"
        signature: "main() -> None"
      - name: "get_ip"
        module: "epaper_ip_display.main"
        signature: "get_ip() -> str | None"
      - name: "draw_text"
        module: "epaper_ip_display.main"
        signature: "draw_text(epd: EPD, line1: str, line2: str) -> None"

tactical_brief: |
  FILE: src/epaper_ip_display/main.py

  TASK: Add subprocess import and change hostname retrieval to FQDN.

  REQUIRED CHANGES (verify each; if already correct do not modify):
  1. Add 'import subprocess' to module-level imports (after 'import socket')
  2. In main(), replace:
       hostname = socket.gethostname()
     with:
       try:
           hostname = subprocess.check_output(['hostname', '-f'], text=True).strip()
       except Exception:
           hostname = socket.gethostname()

  CONSTRAINTS:
  - Modify only src/epaper_ip_display/main.py
  - Preserve all existing logic: shebang, logging config, get_ip(), draw_text(), last_ip cache, sleep(15)
  - Do not touch any other file

  DELIVERABLE: src/epaper_ip_display/main.py with both changes applied.

  SUCCESS: import subprocess present; try/except FQDN block in main(); no other files changed.

notes: "Closed 2026-03-20. Code shipped by AEL, verified on target hardware."

metadata:
  template_version: "1.0"
  schema_type: "t04_prompt"
```
