#!/bin/bash
# build_deb.sh - Creates a native Debian package for 86Box-Pi
# Run this on the Pi or a Linux machine with the artifacts.

set -e

PACKAGE_NAME="86box-pi5"
VERSION="1.0.0"
ARCH="arm64"
PKG_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "=========================================="
echo "Creating Debian Package: $PKG_DIR"
echo "=========================================="

# 1. Create directory structure
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/opt/86box"
mkdir -p "$PKG_DIR/usr/local/bin"
mkdir -p "$PKG_DIR/usr/share/applications"

# 2. Create control file
cat <<EOF > "$PKG_DIR/DEBIAN/control"
Package: $PACKAGE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: Chronic <chronic@pi5dev>
Depends: libsdl2-2.0-0, libqt5widgets5, yad, python3-evdev, gamemode, pipewire, libopenal1, libslirp0, libxkbcommon-x11-0
Description: Optimized 86Box Emulator for Raspberry Pi 5
 Includes native Wayland mouse capture fix and integrated appliance scripts.
EOF

# 3. Create postinst script
cat <<EOF > "$PKG_DIR/DEBIAN/postinst"
#!/bin/bash
set -e

# Link librtmidi for compatibility if needed
if [ -f "/usr/lib/aarch64-linux-gnu/librtmidi.so.7" ] && [ ! -f "/usr/lib/aarch64-linux-gnu/librtmidi.so.6" ]; then
    ln -sf /usr/lib/aarch64-linux-gnu/librtmidi.so.7 /usr/lib/aarch64-linux-gnu/librtmidi.so.6
fi

# Add current users to necessary groups
for user in \$(ls /home); do
    usermod -a -G input,video,render,audio "\$user" || true
done

echo "86Box-Pi5 installed successfully!"
EOF
chmod 755 "$PKG_DIR/DEBIAN/postinst"

# 4. Copy 86Box Binary and ROMs
if [ -f "build_artifacts/86Box" ]; then
    cp build_artifacts/86Box "$PKG_DIR/opt/86box/"
elif [ -f "86Box" ]; then
    cp 86Box "$PKG_DIR/opt/86box/"
else
    echo "Error: 86Box binary not found!"
    exit 1
fi

if [ -d "roms" ]; then
    cp -r roms "$PKG_DIR/opt/86box/"
elif [ -d "build_artifacts/roms" ]; then
    cp -r build_artifacts/roms "$PKG_DIR/opt/86box/"
fi

# 5. Copy Payload Scripts
if [ -d "payload" ]; then
    cp payload/*.py "$PKG_DIR/opt/86box/" || true
    cp payload/*.sh "$PKG_DIR/opt/86box/" || true
fi

# 6. Create the Production Wrapper
cat <<EOF > "$PKG_DIR/usr/local/bin/86box-app"
#!/bin/bash
# 86Box Pi 5 Production Wrapper (Native Wayland)
export QT_QPA_PLATFORM=xcb
export SDL_VIDEODRIVER=wayland
export SDL_VIDEO_WAYLAND_RELATIVE_CURSOR_WARP=1
export GAMEMODE_SILENT=1
exec /opt/86box/86Box "\$@"
EOF
chmod 755 "$PKG_DIR/usr/local/bin/86box-app"

# 7. Create Desktop Entry
cat <<EOF > "$PKG_DIR/usr/share/applications/86box.desktop"
[Desktop Entry]
Name=86Box
Comment=x86 PC Emulator (Optimized for Pi 5)
Exec=86box-app
Icon=system-run
Terminal=false
Type=Application
Categories=Game;Emulator;
EOF

# 8. Set Permissions
chmod +x "$PKG_DIR/opt/86box/86Box"
find "$PKG_DIR/opt/86box" -type f -exec chmod 644 {} +
find "$PKG_DIR/opt/86box" -type d -exec chmod 755 {} +
chmod +x "$PKG_DIR/opt/86box/86Box"
[ -f "$PKG_DIR/opt/86box/input_daemon.py" ] && chmod +x "$PKG_DIR/opt/86box/input_daemon.py"
[ -f "$PKG_DIR/opt/86box/show_menu.sh" ] && chmod +x "$PKG_DIR/opt/86box/show_menu.sh"

# 9. Build the package
dpkg-deb --build "$PKG_DIR"

echo "=========================================="
echo "SUCCESS: ${PKG_DIR}.deb created!"
echo "=========================================="
