# E-Paper IP Display Master Design

---

## Table of Contents

- [Project Information](<#project information>)
- [Scope](<#scope>)
- [System Overview](<#system overview>)
- [Design Constraints](<#design constraints>)
- [Architecture](<#architecture>)
- [Components](<#components>)
- [Data Design](<#data design>)
- [Interfaces](<#interfaces>)
- [Error Handling](<#error handling>)
- [Non-Functional Requirements](<#non-functional requirements>)
- [Visual Documentation](<#visual documentation>)
- [Version History](<#version history>)

---

## Project Information

```yaml
project_info:
  name: "e-Paper IP Display"
  version: "0.1.0"
  date: "2025-11-21"
  author: "William Watson"
```

[Return to Table of Contents](<#table of contents>)

---

## Scope

```yaml
scope:
  purpose: "Display Raspberry Pi WiFi IPv4 address on Waveshare 2.13\" e-Paper HAT V4 with automatic refresh on IP change and systemd service integration"
  
  in_scope:
    - "IPv4 address detection for WiFi interface only"
    - "E-Paper display rendering with centered text"
    - "Automatic IP change detection and display refresh"
    - "Network disconnection handling with 'No Network' display"
    - "Systemd service for automatic startup on boot"
    - "Automated installation and deployment script"
    - "Service restart on failure"
  
  out_scope:
    - "Configuration files"
    - "IPv6 support"
    - "Multiple network interface support"
    - "Ethernet interface detection"
    - "Logging capabilities"
    - "Display customization beyond IP text"
    - "Web interface or remote control"
    - "Multi-display support"
  
  terminology:
    - term: "e-Paper"
      definition: "Waveshare 2.13 inch e-Paper HAT V4 electronic ink display module"
    - term: "HAT"
      definition: "Hardware Attached on Top - Raspberry Pi expansion board"
    - term: "systemd"
      definition: "Linux system and service manager for service lifecycle control"
    - term: "SPI"
      definition: "Serial Peripheral Interface - hardware communication protocol for e-Paper"
```

[Return to Table of Contents](<#table of contents>)

---

## System Overview

```yaml
system_overview:
  description: "Standalone Python application running as systemd service that continuously monitors WiFi interface IPv4 address and displays it on e-Paper screen with minimal refresh to prevent ghosting"
  
  context_flow: "Boot → systemd → Python Service → Network Detection → Display Update → 15s Poll Cycle"
  
  primary_functions:
    - "Detect WiFi interface IPv4 address using socket connection test"
    - "Initialize and control Waveshare e-Paper V4 HAT"
    - "Render centered text displaying current IP or network status"
    - "Poll network status every 15 seconds"
    - "Update display only when IP changes"
    - "Handle network unavailability gracefully"
    - "Run continuously as background service"
```

[Return to Table of Contents](<#table of contents>)

---

## Design Constraints

```yaml
design_constraints:
  technical:
    - "Raspberry Pi OS (Debian-based Linux)"
    - "Python 3.x runtime environment"
    - "SPI interface must be enabled via raspi-config"
    - "GPIO access required for e-Paper control"
    - "Network interface must be WiFi (not Ethernet)"
    - "Single process execution model"
    - "E-Paper refresh limitations (ghosting prevention)"
  
  implementation:
    language: "Python 3"
    framework: "None (standard library + hardware libraries)"
    libraries:
      - "socket (standard library)"
      - "time (standard library)"
      - "PIL (Pillow - Python Imaging Library)"
      - "waveshare_epd.epd2in13_V4 (Waveshare driver)"
    standards:
      - "No logging output"
      - "Minimal refresh strategy (change detection only)"
      - "Hardcoded 'pi' user execution context"
      - "Fixed 15-second polling interval"
  
  performance_targets:
    - metric: "Polling interval"
      value: "15 seconds"
    - metric: "Display refresh"
      value: "Only on IP change"
    - metric: "Network detection timeout"
      value: "Socket connection default timeout"
```

[Return to Table of Contents](<#table of contents>)

---

## Architecture

```yaml
architecture:
  pattern: "Event-driven polling loop with state caching"
  
  component_relationships: "systemd → Main Loop → IP Detector → Display Controller → e-Paper Driver"
  
  technology_stack:
    language: "Python 3"
    framework: "systemd service manager"
    libraries:
      - "PIL (Pillow) for image rendering"
      - "waveshare_epd.epd2in13_V4 for e-Paper control"
      - "socket for network detection"
      - "time for polling interval"
    data_store: "None (stateless except in-memory IP cache)"
  
  directory_structure:
    - "/home/pi/epaper-ip/ - Application directory"
    - "/home/pi/epaper-ip/epaper_ip_display.py - Main application"
    - "/home/pi/epaper-ip/epd2in13_V4.py - Waveshare driver"
    - "/etc/systemd/system/epaper-ip-display.service - Service definition"
```

[Return to Table of Contents](<#table of contents>)

---

## Components

### Main Application Loop

```yaml
- name: "Main Application Loop"
  purpose: "Coordinate continuous IP monitoring and display updates with state change detection"
  
  responsibilities:
    - "Initialize e-Paper display hardware"
    - "Clear display on startup"
    - "Execute infinite polling loop"
    - "Cache previous IP state for change detection"
    - "Trigger display updates only on state change"
    - "Enforce 15-second polling interval"
  
  inputs:
    - field: "None (service start trigger)"
      type: "systemd signal"
      description: "Service start/restart command"
  
  outputs:
    - field: "Display update"
      type: "e-Paper render command"
      description: "Updated IP or status text on screen"
  
  key_elements:
    - name: "main"
      type: "function"
      purpose: "Entry point - initialize display and run polling loop"
  
  dependencies:
    internal:
      - "IP Detection Module"
      - "Display Controller Module"
    external:
      - "waveshare_epd.epd2in13_V4"
      - "time.sleep"
  
  processing_logic:
    - "Initialize e-Paper display object"
    - "Clear display to white"
    - "Set last_ip cache to None"
    - "Enter infinite while loop:"
    - "  Get current IP from IP Detection Module"
    - "  Format text: 'IP: {ip}' or 'No Network'"
    - "  Compare with cached last_ip"
    - "  If different, call Display Controller to update"
    - "  Update last_ip cache"
    - "  Sleep 15 seconds"
  
  error_conditions:
    - condition: "e-Paper initialization failure"
      handling: "Allow exception to propagate for systemd restart"
    - condition: "Display update failure"
      handling: "Allow exception to propagate for systemd restart"
```

[Return to Table of Contents](<#table of contents>)

### IP Detection Module

```yaml
- name: "IP Detection Module"
  purpose: "Detect WiFi interface IPv4 address using socket connection probe"
  
  responsibilities:
    - "Create UDP socket connection to external host"
    - "Extract local IP address from socket binding"
    - "Return None on network unavailability"
    - "Close socket resources properly"
  
  inputs:
    - field: "None (uses system network state)"
      type: "implicit"
      description: "Current network interface configuration"
  
  outputs:
    - field: "ip_address"
      type: "str or None"
      description: "IPv4 address string (e.g., '192.168.1.100') or None if no network"
  
  key_elements:
    - name: "get_ip"
      type: "function"
      purpose: "Detect WiFi IPv4 address via socket connection test"
  
  dependencies:
    internal: []
    external:
      - "socket.socket"
      - "socket.AF_INET"
      - "socket.SOCK_DGRAM"
  
  processing_logic:
    - "Create UDP socket (AF_INET, SOCK_DGRAM)"
    - "Connect to 8.8.8.8:80 (does not send data, establishes route)"
    - "Extract local address from socket.getsockname()[0]"
    - "Close socket"
    - "Return IP address string"
    - "On any exception, return None"
  
  error_conditions:
    - condition: "No network available"
      handling: "Return None"
    - condition: "Socket creation failure"
      handling: "Return None via exception catch"
```

[Return to Table of Contents](<#table of contents>)

### Display Controller Module

```yaml
- name: "Display Controller Module"
  purpose: "Render text on e-Paper display with centered layout"
  
  responsibilities:
    - "Create blank white image buffer"
    - "Render text centered on display"
    - "Send image buffer to e-Paper hardware"
    - "Use default system font"
  
  inputs:
    - field: "epd"
      type: "epd2in13_V4.EPD"
      description: "Initialized e-Paper display object"
    - field: "text"
      type: "str"
      description: "Text to display (IP address or status message)"
  
  outputs:
    - field: "None (side effect: display updated)"
      type: "void"
      description: "Text rendered on physical e-Paper screen"
  
  key_elements:
    - name: "draw_text"
      type: "function"
      purpose: "Render centered text on e-Paper display"
  
  dependencies:
    internal: []
    external:
      - "PIL.Image"
      - "PIL.ImageDraw"
      - "PIL.ImageFont"
  
  processing_logic:
    - "Create new image: Image.new('1', (epd.width, epd.height), 255)"
    - "Create drawing context: ImageDraw.Draw(image)"
    - "Load default font: ImageFont.load_default()"
    - "Calculate text dimensions: draw.textsize(text, font=font)"
    - "Calculate centered position: x=(width-w)//2, y=(height-h)//2"
    - "Draw text: draw.text((x, y), text, font=font, fill=0)"
    - "Convert to buffer: epd.getbuffer(image)"
    - "Display: epd.display(buffer)"
  
  error_conditions:
    - condition: "Display hardware communication failure"
      handling: "Allow exception to propagate"
```

[Return to Table of Contents](<#table of contents>)

### Installation Framework

```yaml
- name: "Installation Framework"
  purpose: "Automated deployment and systemd service configuration"
  
  responsibilities:
    - "Create application directory structure"
    - "Copy application files to target location"
    - "Install system dependencies via apt"
    - "Configure systemd service"
    - "Enable and start service"
  
  inputs:
    - field: "epaper_ip_display.py"
      type: "file"
      description: "Main application script"
    - field: "epd2in13_V4.py"
      type: "file"
      description: "Waveshare driver file"
    - field: "epaper-ip-display.service"
      type: "file"
      description: "systemd service definition"
  
  outputs:
    - field: "Installed service"
      type: "systemd service"
      description: "Running e-Paper IP display service"
  
  key_elements:
    - name: "epaper-ip-install.sh"
      type: "function"
      purpose: "Shell script for automated installation"
  
  dependencies:
    internal: []
    external:
      - "bash shell"
      - "systemctl"
      - "apt-get"
  
  processing_logic:
    - "Set variables: INSTALL_DIR=/home/pi/epaper-ip"
    - "Create directory: mkdir -p $INSTALL_DIR"
    - "Copy files: cp scripts and drivers to $INSTALL_DIR"
    - "Copy service: cp service file to /etc/systemd/system/"
    - "Make executable: chmod +x $INSTALL_DIR/epaper_ip_display.py"
    - "Update apt: sudo apt-get update"
    - "Install dependencies: python3-pil python3-spidev python3-rpi.gpio"
    - "Reload systemd: systemctl daemon-reload"
    - "Enable service: systemctl enable epaper-ip-display.service"
    - "Start service: systemctl restart epaper-ip-display.service"
  
  error_conditions:
    - condition: "Installation script failure"
      handling: "Exit with error (set -e enforced)"
```

[Return to Table of Contents](<#table of contents>)

---

## Data Design

```yaml
data_design:
  entities:
    - name: "IP State Cache"
      purpose: "Track previous IP address to detect changes"
      attributes:
        - name: "last_ip"
          type: "str or None"
          constraints: "In-memory variable, not persisted"
      relationships: []
  
  storage: []
  
  validation_rules:
    - "IP address must be valid IPv4 format (implicit via socket)"
    - "Display text limited to e-Paper display dimensions"
```

[Return to Table of Contents](<#table of contents>)

---

## Interfaces

### Internal Interfaces

```yaml
interfaces:
  internal:
    - name: "get_ip"
      purpose: "Retrieve current WiFi IPv4 address"
      signature: "get_ip() -> str | None"
      parameters: []
      returns:
        type: "str or None"
        description: "IPv4 address string or None if network unavailable"
      raises: []
    
    - name: "draw_text"
      purpose: "Render text on e-Paper display"
      signature: "draw_text(epd: EPD, text: str) -> None"
      parameters:
        - name: "epd"
          type: "epd2in13_V4.EPD"
          description: "Initialized e-Paper display object"
        - name: "text"
          type: "str"
          description: "Text to display"
      returns:
        type: "None"
        description: "Side effect: updates physical display"
      raises: []
    
    - name: "main"
      purpose: "Application entry point and polling loop"
      signature: "main() -> None"
      parameters: []
      returns:
        type: "None"
        description: "Runs indefinitely until terminated"
      raises: []
```

### External Interfaces

```yaml
  external:
    - name: "Waveshare e-Paper Driver"
      protocol: "Python library import"
      data_format: "Native Python objects"
      specification: "waveshare_epd.epd2in13_V4.EPD class with init(), Clear(), display(), getbuffer() methods"
    
    - name: "systemd Service Manager"
      protocol: "systemd service definition"
      data_format: "INI-style service file"
      specification: "Type=simple, User=pi, WorkingDirectory=/home/pi/epaper-ip, ExecStart=/usr/bin/python3 script path"
    
    - name: "Network Interface"
      protocol: "Socket UDP connection probe"
      data_format: "IPv4 address string"
      specification: "Socket connection to 8.8.8.8:80 to determine routing interface"
```

[Return to Table of Contents](<#table of contents>)

---

## Error Handling

```yaml
error_handling:
  exception_hierarchy:
    base: "Python Exception"
    specific: []
  
  strategy:
    validation_errors: "No explicit validation - rely on socket and driver exceptions"
    runtime_errors: "Propagate all exceptions to systemd for service restart"
    external_failures: "Return None from get_ip() on network failures, propagate display failures"
  
  logging:
    levels: []
    required_info: []
    format: "No logging implemented per requirements"
```

[Return to Table of Contents](<#table of contents>)

---

## Non-Functional Requirements

```yaml
nonfunctional_requirements:
  performance:
    - metric: "Polling frequency"
      target: "15 seconds between network checks"
    - metric: "Display refresh"
      target: "Only when IP changes to minimize e-Paper wear"
    - metric: "Startup time"
      target: "Display active within 30 seconds of boot"
  
  security:
    authentication: "None - local hardware access only"
    authorization: "systemd runs as 'pi' user with GPIO/SPI permissions"
    data_protection:
      - "No sensitive data stored or transmitted"
      - "IP address displayed in plaintext on physical screen"
  
  reliability:
    error_recovery: "systemd restarts service on failure (Restart=always, RestartSec=5)"
    fault_tolerance:
      - "Network disconnection handled gracefully with 'No Network' display"
      - "Service auto-restart on crash"
  
  maintainability:
    code_organization:
      - "Single-file application with clear function separation"
      - "Waveshare driver isolated in separate file"
    documentation:
      - "Function-level inline documentation"
      - "Installation guide embedded in shell script comments"
    testing:
      coverage_target: "Not specified"
      approaches:
        - "Manual integration testing on target hardware"
        - "systemd service lifecycle verification"
```

[Return to Table of Contents](<#table of contents>)

---

## Visual Documentation

### System Architecture

```mermaid
graph TB
    subgraph "Boot Sequence"
        Boot[Raspberry Pi Boot] --> SystemD[systemd Service Manager]
    end
    
    subgraph "Application Layer"
        SystemD -->|starts| MainLoop[Main Application Loop]
        MainLoop -->|initialize| EPaper[e-Paper Display]
        MainLoop -->|clear| EPaper
    end
    
    subgraph "Polling Cycle"
        MainLoop -->|every 15s| IPDetect[IP Detection Module]
        IPDetect -->|socket probe| Network[WiFi Network Interface]
        Network -->|return IP| IPDetect
        IPDetect -->|IP or None| StateCheck{IP Changed?}
        StateCheck -->|Yes| DisplayCtrl[Display Controller]
        StateCheck -->|No| Sleep[Sleep 15s]
        DisplayCtrl -->|render text| ImageRender[PIL Image Rendering]
        ImageRender -->|buffer| EPaperDriver[Waveshare Driver]
        EPaperDriver -->|SPI/GPIO| EPaper
        DisplayCtrl --> Sleep
        Sleep --> IPDetect
    end
    
    subgraph "Hardware Layer"
        EPaper[e-Paper HAT V4]
        GPIO[GPIO Pins]
        SPI[SPI Interface]
        EPaper -.->|hardware| GPIO
        EPaper -.->|hardware| SPI
    end
    
    subgraph "Error Recovery"
        MainLoop -.->|exception| SystemD
        SystemD -.->|restart after 5s| MainLoop
    end
    
    style Boot fill:#e1f5ff
    style SystemD fill:#fff4e1
    style MainLoop fill:#e8f5e8
    style EPaper fill:#ffe1e1
```

**Purpose:** Illustrates system initialization sequence, polling cycle logic, hardware interaction, and error recovery mechanism.

**Legend:**
- Solid arrows: Control flow and data flow
- Dashed arrows: Error handling and hardware connections
- Rectangles: Software components
- Diamond: Decision point (state change detection)
- Rounded rectangles: Hardware components

[Return to Table of Contents](<#table of contents>)

### Component Interaction

```mermaid
sequenceDiagram
    participant SD as systemd
    participant ML as Main Loop
    participant ID as IP Detector
    participant DC as Display Controller
    participant DRV as Waveshare Driver
    participant HW as e-Paper HAT
    
    SD->>ML: Start Service
    ML->>DRV: epd.init()
    DRV->>HW: Initialize SPI/GPIO
    HW-->>DRV: Ready
    ML->>DRV: epd.Clear()
    DRV->>HW: Clear Display
    
    loop Every 15 seconds
        ML->>ID: get_ip()
        ID->>ID: socket.connect(8.8.8.8:80)
        alt Network Available
            ID-->>ML: "192.168.1.100"
        else No Network
            ID-->>ML: None
        end
        
        ML->>ML: Compare with last_ip
        
        alt IP Changed
            ML->>DC: draw_text(epd, "IP: 192.168.1.100")
            DC->>DC: Create image buffer
            DC->>DC: Calculate centered position
            DC->>DC: Draw text on buffer
            DC->>DRV: epd.display(buffer)
            DRV->>HW: Update Display
            HW-->>DRV: Complete
            DC-->>ML: Done
        else IP Unchanged
            ML->>ML: Skip display update
        end
        
        ML->>ML: sleep(15)
    end
    
    Note over ML,HW: On any exception, systemd restarts service
```

**Purpose:** Shows temporal sequence of operations during normal polling cycle and display refresh.

**Legend:**
- Solid arrows: Synchronous calls
- Dashed arrows: Return values
- Loop box: Continuous polling cycle
- Alt box: Conditional logic branches

[Return to Table of Contents](<#table of contents>)

### State Machine

```mermaid
stateDiagram-v2
    [*] --> Initializing: systemd start
    
    Initializing --> Polling: e-Paper initialized & cleared
    Initializing --> Error: Init failure
    
    Polling --> NetworkCheck: 15s timer expired
    NetworkCheck --> IPDetected: Socket successful
    NetworkCheck --> NoNetwork: Socket failed
    
    IPDetected --> CompareState: Get IP address
    NoNetwork --> CompareState: Format "No Network"
    
    CompareState --> DisplayUpdate: IP changed
    CompareState --> Waiting: IP unchanged
    
    DisplayUpdate --> Waiting: Display refreshed
    Waiting --> Polling: Continue loop
    
    Error --> [*]: systemd restarts service (5s delay)
    
    note right of Initializing
        - Initialize EPD object
        - Clear display to white
        - Set last_ip = None
    end note
    
    note right of NetworkCheck
        - UDP socket to 8.8.8.8:80
        - Extract local IP
        - Close socket
    end note
    
    note right of CompareState
        - last_ip cached in memory
        - Only update if different
    end note
    
    note right of DisplayUpdate
        - Center text on display
        - Convert to e-Paper buffer
        - SPI/GPIO update
    end note
```

**Purpose:** Defines service lifecycle states and transition conditions.

**Legend:**
- Rounded rectangles: System states
- Arrows: State transitions with trigger conditions
- Notes: Key operations in each state

[Return to Table of Contents](<#table of contents>)

### Installation and Deployment Flow

```mermaid
flowchart TD
    Start([User Executes Install Script]) --> CheckRoot{Run as<br/>sudo?}
    CheckRoot -->|No| AskSudo[Prompt for sudo]
    AskSudo --> Start
    CheckRoot -->|Yes| CreateDir[Create /home/pi/epaper-ip/]
    
    CreateDir --> CopyFiles[Copy Python Scripts]
    CopyFiles --> CopyService[Copy systemd Service File<br/>to /etc/systemd/system/]
    CopyService --> ChmodExec[chmod +x on Python script]
    
    ChmodExec --> AptUpdate[sudo apt-get update]
    AptUpdate --> InstallDeps[Install Dependencies:<br/>python3-pil<br/>python3-spidev<br/>python3-rpi.gpio]
    
    InstallDeps --> Reload[systemctl daemon-reload]
    Reload --> Enable[systemctl enable<br/>epaper-ip-display.service]
    Enable --> Start2[systemctl restart<br/>epaper-ip-display.service]
    
    Start2 --> Verify{Service<br/>Running?}
    Verify -->|Yes| Success([Installation Complete])
    Verify -->|No| ShowStatus[Display systemctl status]
    ShowStatus --> Fail([Installation Failed])
    
    Success --> Runtime[Service runs on every boot]
    
    style Start fill:#e1f5ff
    style Success fill:#e8f5e8
    style Fail fill:#ffe1e1
    style Runtime fill:#fff4e1
```

**Purpose:** Documents automated installation process and deployment verification steps.

**Legend:**
- Rounded rectangles: Start/end points
- Rectangles: Installation steps
- Diamonds: Decision points
- Solid arrows: Sequential flow

[Return to Table of Contents](<#table of contents>)

---

## Version History

| Version | Date       | Author          | Changes                          |
| ------- | ---------- | --------------- | -------------------------------- |
| 0.1.0   | 2025-11-21 | William Watson  | Initial master design document   |

[Return to Table of Contents](<#table of contents>)

---

**Copyright:** Copyright (c) 2025 William Watson. This work is licensed under the MIT License.