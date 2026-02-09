# 86Box-Pi 5: Optimized x86 Emulation Appliance

[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi%205-red)](https://www.raspberrypi.com/products/raspberry-pi-5/)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue)](https://github.com/86Box/86Box/blob/master/COPYING)

86Box-Pi 5 is a specialized distribution of the [86Box](https://86box.net) emulator, meticulously tuned for the **Raspberry Pi 5**. This project transforms your SBC into a dedicated "Retro PC Appliance," capable of running Windows 9x and early Pentium-era software with cycle-accurate timing and native Wayland support.

## 🚀 Why This Project?

Unlike generic emulators, this project addresses the specific challenges of running 86Box on ARM64 Wayland hosts:
*   **Performance**: Uses the optimized New Dynarec (NDR) for Cortex-A76.
*   **Mouse Capture Fix**: Native Wayland implementation for perfect mouse locking (no more cursor escaping!).
*   **Appliance Logic**: Integrated hotkey menu (F8+F12) for managing settings, disks, and power without leaving the emulated environment.
*   **Auto-Deployment**: Scripted installers that handle dependencies, groups, and ROMs automatically.

---

## 🛠 Choose Your Installation Path

### 1. The Professional Way (Native `.deb` Package)
**Best for most users.** Install 86Box as a standard application on Raspberry Pi OS.
1. Download the latest `.deb` from the [Releases](https://github.com/chronic8000/86box-pi5/releases) page.
2. Install it via terminal:
   ```bash
   sudo apt install ./86box-pi5_1.0.0_arm64.deb
   ```
3. Launch "86Box" from the **Applications -> Games** menu.

### 2. The Developer Way (Remote Deployment)
**Best for those working from a PC.** Push the 86Box environment to your Pi over the network.
1. Clone this repo on your Windows/WSL machine.
2. Run the deployment orchestrator:
   ```bash
   ./deploy_to_pi.sh [PI_IP_ADDRESS]
   ```
   *This automatically installs dependencies, ROMs, and the native Wayland wrapper.*

### 3. The "Golden Master" Way (Full Image Builder)
**Best for building dedicated appliances.** Generate a custom `.img` file that boots directly into 86Box.
1. Use WSL/Docker to run the automated build script:
   ```bash
   sudo ./build.sh
   ```
2. Flash the resulting `86box-pi5-appliance.img` to an SD card.

---

## 🖱️ The Wayland Mouse Fix

Raspberry Pi OS (Bookworm) uses the Wayland compositor, which standard emulators struggle with. We've solved this by implementing a **Hybrid Wrapper**:
*   **Stable UI**: Uses X11 compatibility for the manager window to prevent hangs.
*   **Native Input**: Uses SDL's Relative Pointer protocol to "grab" the mouse hardware, ensuring your Windows 98 cursor is perfectly synced.

---

## ⌨️ Controls & Usage

*   **F8 + F12**: Opens the **Appliance Control Menu** (Settings, Reset, Media, Shutdown).
*   **Ctrl + End**: Release mouse capture.
*   **VMware Mouse**: For the smoothest experience (especially over VNC), we recommend setting the emulated mouse to **VMware Mouse (vmmouse)** in 86Box settings.

---

## 📂 Project Structure

*   **/scripts**: Toolchains for cross-compilation and `.deb` packaging.
*   **/payload**: Scripts for the Appliance UI and background monitoring.
*   **/86box-image-builder**: The core logic for generating standalone OS images.

---

## ❤️ Credits
*   The [86Box Team](https://github.com/86Box/86Box) for the incredible emulator.
*   [Labwc](https://github.com/labwc/labwc) for the lightweight Wayland compositor.

---
*For detailed configuration help, see the [USER_GUIDE.md](USER_GUIDE.md).*
