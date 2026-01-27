# 86Box Raspberry Pi 5 Appliance: User Guide

Welcome to your dedicated x86 emulation appliance! This system turns your Raspberry Pi 5 into a dedicated Pentium/486 emulator that boots directly into the guest OS.

## 1. Installation

1.  **Get the Image**: Locate the `86box-pi5-appliance.img` file built by the instructions.
2.  **Flash to SD Card**:
    *   Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
    *   **model**: Raspberry Pi 5.
    *   **OS**: Use Custom Image (Select the `.img` file).
    *   **Storage**: Select your SD Card (32GB+ recommended).
    *   **Settings**: You can SKIP OS Customization (Wi-Fi/SSH settings in Imager *might* trigger, but our image has its own overrides).
3.  **Insert & Power On**: Insert the card into your Pi 5 and connect power.

## 2. Startup Behavior

*   **Boot Time**: ~15-30 seconds.
*   **Silence**: The boot process is designed to be "silent". You will see a black screen for a few seconds. Do not panic.
*   **Launch**: 86Box will automatically launch in full-screen mode.

## 3. Controlling the Appliance

Since the emulator runs full-screen, you need special hotkeys to access configuration.

### The "Magic Combo": **F8 + F12**
Press and hold **F8** and **F12** together to bring up the **System Control Menu**.

From this menu you can:
*   **Resume**: Return to the emulator.
*   **Settings**: Open the internal 86Box configuration (Hardware, Drives, Video).
*   **Reset**: Hard reset the emulated machine.
*   **Shutdown**: Safely power off the Raspberry Pi.

### Important 86Box Controls
- **F8 + F12**: Open the **Appliance Menu** (Pause, Settings, Reset, Shutdown).
- **Ctrl + End**: Release mouse capture (Native 86Box behavior).
- **Ctrl + Alt + S**: Open Settings (Must be mapped in 86Box settings!).

> [!TIP]
> **Enable the Settings Menu Button**:
> By default, 86Box v5.0 does not have a hotkey for "Open Settings".
> 1. Press **Ctrl+End** to release the mouse.
> 2. Access the menu bar (if visible) or Manager.
> 3. Go to **Settings > Input > Key bindings**.
> 4. Map **"Open Settings"** to `Ctrl + Alt + S`.
> Now the "Settings" button in your F8+F12 menu will work!
*   **Ctrl + Alt + P** (Default): Pause emulation.

## 4. Transferring Files (Games/OS)

The appliance runs a lightweight Linux host in the background. The best way to transfer files is via **SFTP/SSH**.

**Default Credentials:**
*   **User**: `pi`
*   **Password**: `raspberry` (or whatever was set during image building/first boot if OS customization applied).
    *   *Note: If you used the raw image builder without customization, the user is `pi`.*

**Steps:**
1.  Connect the Pi to Ethernet (or configure Wi-Fi via `raspi-config` if you can get to a terminal).
2.  Use an SFTP client (like WinSCP or FileZilla) on your PC.
3.  Connect to the Pi's IP address.
4.  Navigate to `/home/pi/vm/`.
5.  Upload your hard disk images (`.img`, `.vhd`), CD images (`.iso`), or floppy images (`.img`) here.

## 5. Configuring the VM

1.  Press **F8+F12** -> **Settings**.
2.  Go to **Storage Controllers** / **Hard Disks**.
3.  Add your uploaded drive images.
4.  Save and **Hard Reset**.

## 6. Audio Latency

This appliance uses **PipeWire** configured for low latency (~20ms). If you experience crackling:
1.  Open 86Box Settings.
2.  Go to **Sound**.
3.  Ensure the buffer size is low but stable.
4.  Verify you are emulating a machine speed the Pi 5 can handle (Pentium MMX 233 is the recommended sweet spot).
