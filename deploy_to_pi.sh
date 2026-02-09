#!/bin/bash
# deploy_to_pi.sh - Deploy 86Box Appliance to a live Pi 5 from WSL
# Usage: ./deploy_to_pi.sh [PI_IP] [PI_USER]

PI_IP=${1:-"192.168.18.22"}
PI_USER=${2:-"pi"}

echo "=========================================="
echo "   86Box Pi Deployment Orchestrator       "
echo "=========================================="
echo "Target: $PI_USER@$PI_IP"

# 1. Check for compiled artifacts
BUILD_FOUND="y"
if [ ! -f "build_artifacts/86Box" ]; then
    echo "Warning: Optimized 86Box binary not found in build_artifacts/."
    echo "The installer on the Pi will instead download the official 86Box NDR release."
    BUILD_FOUND="n"
fi

# 2. Prepare bundle
echo "Preparing deployment bundle..."
TEMP_DIR="deploy_temp"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/payload"

if [ "$BUILD_FOUND" == "y" ]; then
    cp build_artifacts/86Box "$TEMP_DIR/"
    cp -r build_artifacts/roms "$TEMP_DIR/"
else
    # We still need to create a dummy structure or ensure the folders exist
    # If roms are mission, we might want to warn
    echo "Searching for ROMs in current directory..."
    [ -d "roms" ] && cp -r roms "$TEMP_DIR/"
fi
cp -r payload/* "$TEMP_DIR/payload/"
cp scripts/install_on_pi.sh "$TEMP_DIR/"

# 3. Transfer to Pi
echo "Transferring files to Pi (this may take a moment)..."
# We exclude things if necessary, but here we just copy the temp dir
scp -r "$TEMP_DIR"/* "$PI_USER@$PI_IP:~/86box_install/"

# 4. Execute Installer
echo "Starting remote installation..."
ssh -t "$PI_USER@$PI_IP" "cd ~/86box_install && chmod +x install_on_pi.sh && sudo ./install_on_pi.sh"

# 5. Cleanup
echo "Cleaning up local bundle..."
rm -rf "$TEMP_DIR"

echo "=========================================="
echo "      DEPLOYMENT SUCCESSFUL               "
echo "=========================================="
echo "Your 86Box appliance is now installed on the Pi."
echo "Login via SSH/VNC and run 'startx' to begin."
echo "=========================================="
