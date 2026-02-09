# Installing 86Box on a Live Pi 5 (Desktop Mode)

This guide covers how to install 86Box as a standard desktop application on Raspberry Pi OS (Bookworm).

## New Features
- **AppImage Support**: If no locally built 86Box is found, the installer will automatically download the official **86Box v5.3 ARM64 NDR** release.
- **Desktop Shortcut**: 86Box will appear in your "Games" or "Emulators" menu.
- **Optional Appliance Mode**: You choose whether to keep your current desktop or boot straight into 86Box.

## Method 1: Automated Deployment (from WSL)

1.  **Run the deployment script**:
    ```bash
    chmod +x deploy_to_pi.sh
    ./deploy_to_pi.sh 192.168.18.22 chronic
    ```
2.  **Follow the prompts** on the terminal.

---

## Post-Installation Setup

### 1. Launching
You can find 86Box in your Pi's Application Menu, or run it from the terminal:
`86box-app`

### 2. VM Configuration
The installer creates a default directory for your VMs:
`~/vm/default`

### 3. F8 + F12 Appliance Menu
The hotkey daemon is installed to `/opt/86box/`. You can launch it manually or add it to your startup applications to keep the "Appliance" features (Settings/Reset menu) active even on the desktop.
