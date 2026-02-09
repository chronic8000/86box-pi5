# install_on_pi.sh - Installer for 86Box on Raspberry Pi OS (Desktop or Lite)
# Designed to be run on the Pi itself.

echo "=========================================="
echo "   86Box Pi Deployment Tool              "
echo "=========================================="

# 1. Check for Sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

set -e

# 2. Setup Directory
TARGET_DIR="/opt/86box"
mkdir -p "$TARGET_DIR"

echo "Current Directory: $(pwd)"

# 3. Choose Binary Source
USE_OFFICIAL="n"
if [ -f "86Box" ]; then
    echo "Found optimized local 86Box binary."
else
    echo "No local binary found. Will download official 86Box ARM64 NDR release."
    USE_OFFICIAL="y"
fi

if [ "$USE_OFFICIAL" == "y" ]; then
    echo "Downloading official 86Box v5.3 ARM64 NDR..."
    # URL for v5.3 NDR AppImage
    URL="https://github.com/86Box/86Box/releases/download/v5.3/86Box-NDR-Linux-arm64-b8200.AppImage"
    wget -q "$URL" -O "$TARGET_DIR/86Box"
    chmod +x "$TARGET_DIR/86Box"
else
    echo "Copying local optimized 86Box..."
    cp 86Box "$TARGET_DIR/"
fi

# 4. Copy ROMs and Payload
if [ -d "roms" ]; then
    echo "Copying ROMs..."
    cp -r roms "$TARGET_DIR/"
fi

if [ -d "payload" ]; then
    echo "Copying Payload scripts..."
    cp -r payload/* "$TARGET_DIR/"
fi

# 5. Install Dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y \
    git \
    libqt5widgets5 \
    libqt5gui5 \
    libsdl2-2.0-0 \
    libopenal1 \
    libfreetype6 \
    libglib2.0-0 \
    libslirp0 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libserialport0 \
    xdotool \
    yad \
    python3-evdev \
    libgl1 \
    gamemode \
    pipewire \
    pipewire-alsa \
    pipewire-pulse

# 5.1 Optional MIDI/Synth libraries (might have different names on some distros)
echo "Installing optional MIDI support..."
apt-get install -y librtmidi7 || apt-get install -y librtmidi6 || apt-get install -y librtmidi4 || echo "Warning: librtmidi not found."
apt-get install -y libfluidsynth3 || apt-get install -y libfluidsynth2 || echo "Warning: libfluidsynth not found."

# 5.2 Link librtmidi if version mismatch (Common on Bookworm asking for .6)
if [ -f "/usr/lib/aarch64-linux-gnu/librtmidi.so.7" ] && [ ! -f "/usr/lib/aarch64-linux-gnu/librtmidi.so.6" ]; then
    echo "Linking librtmidi.so.7 -> librtmidi.so.6 for compatibility..."
    ln -sf /usr/lib/aarch64-linux-gnu/librtmidi.so.7 /usr/lib/aarch64-linux-gnu/librtmidi.so.6
fi

# 5.5 Download ROMs if missing
if [ ! -d "$TARGET_DIR/roms" ] || [ -z "$(ls -A $TARGET_DIR/roms)" ]; then
    echo "ROMs missing or empty. Downloading official 86Box ROM set..."
    rm -rf "$TARGET_DIR/roms"
    git clone --depth 1 https://github.com/86Box/roms.git "$TARGET_DIR/roms"
    rm -rf "$TARGET_DIR/roms/.git"
else
    echo "ROMs already present in $TARGET_DIR/roms."
fi

# 6. Permissions and Links
echo "Configuring permissions..."
# Ensure everyone can read/enter the directory and roms
chmod -R a+rX "$TARGET_DIR" 
chmod +x "$TARGET_DIR/86Box"
[ -f "$TARGET_DIR/input_daemon.py" ] && chmod +x "$TARGET_DIR/input_daemon.py"
[ -f "$TARGET_DIR/show_menu.sh" ] && chmod +x "$TARGET_DIR/show_menu.sh"

# Link binaries for CLI usage (Production wrapper)
rm -f /usr/local/bin/86box-app
cat <<EOF > /usr/local/bin/86box-app
#!/bin/bash
# 86Box Pi 5 Production Wrapper (Native Wayland)

# Hybrid Mode: Stable UI + Native Mouse Capture
export QT_QPA_PLATFORM=xcb
export SDL_VIDEODRIVER=wayland
export SDL_VIDEO_WAYLAND_RELATIVE_CURSOR_WARP=1
export GAMEMODE_SILENT=1

# Run the emulator
exec /opt/86box/86Box "\$@"
EOF
chmod +x /usr/local/bin/86box-app

# If we have the daemon, link it
[ -f "$TARGET_DIR/input_daemon.py" ] && ln -sf "$TARGET_DIR/input_daemon.py" /usr/local/bin/86box-input-daemon

# Add current user to groups
CURRENT_USER=$(logname || echo $USER)
usermod -a -G input,video,render,audio "$CURRENT_USER"

# 7. Desktop Integration
DESKTOP_ENTRY="/usr/share/applications/86box.desktop"
echo "Creating Desktop entry at $DESKTOP_ENTRY..."
cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Name=86Box
Comment=x86 PC Emulator
Exec=86box-app
Icon=system-run
Terminal=false
Type=Application
Categories=Game;Emulator;
EOF

# 8. Appliance Service (Optional)
echo "------------------------------------------"
echo "Appliance Mode (Experimental)"
echo "This will make the Pi boot straight into 86Box."
read -p "Do you want to enable Appliance Mode? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$TARGET_DIR/retro-pc.service" ]; then
        cp "$TARGET_DIR/retro-pc.service" /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable retro-pc.service
        echo "Appliance mode enabled."
    else
        echo "Warning: retro-pc.service not found. Skipping."
    fi
fi

# 9. xinitrc (Only for Lite/Appliance users)
XINITRC_PATH="/home/$CURRENT_USER/.xinitrc"
if [ ! -f "$XINITRC_PATH" ] && [ -f "$TARGET_DIR/xinitrc" ]; then
    echo "Setting up .xinitrc for Lite boot..."
    cp "$TARGET_DIR/xinitrc" "$XINITRC_PATH"
    chown "$CURRENT_USER:$CURRENT_USER" "$XINITRC_PATH"
    chmod +x "$XINITRC_PATH"
fi

echo "=========================================="
echo "      INSTALLATION COMPLETE               "
echo "=========================================="
echo "1. 86Box is now in your Applications menu (Games/Emulators)."
echo "2. Your VM configuration should go in /home/$CURRENT_USER/vm/default"
echo "3. The F8+F12 hotkey daemon is in /opt/86box/input_daemon.py"
echo "=========================================="
