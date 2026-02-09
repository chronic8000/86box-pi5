# deploy_to_pi.ps1 - Deploy 86Box Appliance to a live Pi 5 from Windows PowerShell
# Usage: .\deploy_to_pi.ps1 -PiIp "192.168.18.22" -PiUser "chronic"

param (
    [string]$PiIp = "192.168.18.22",
    [string]$PiUser = "chronic"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   86Box Pi Deployment Orchestrator (PS)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Target: $PiUser@$PiIp"

# 1. Check for compiled artifacts (might be in WSL filesystem, but accessible via \\wsl.localhost)
$ArtifactPath = "build_artifacts\86Box"
if (-not (Test-Path $ArtifactPath)) {
    Write-Host "Error: 86Box binary not found in build_artifacts/." -ForegroundColor Red
    Write-Host "Please ensure you have run the build in WSL first." -ForegroundColor Red
    exit 1
}

# 2. Prepare bundle
Write-Host "Preparing deployment bundle..."
$TempDir = "deploy_temp"
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
New-Item -ItemType Directory -Path "$TempDir\payload" | Out-Null

Copy-Item $ArtifactPath "$TempDir\"
if (Test-Path "build_artifacts\roms") {
    Copy-Item -Recurse "build_artifacts\roms" "$TempDir\"
}
Copy-Item -Recurse "payload\*" "$TempDir\payload\"
Copy-Item "scripts\install_on_pi.sh" "$TempDir\"

# 3. Transfer to Pi
Write-Host "Transferring files to Pi (this may take a moment)..."
# Use Windows native scp
scp -r "$TempDir/*" "$PiUser@$($PiIp):~/86box_install/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Transfer failed. Is the Pi reachable at $PiIp?" -ForegroundColor Red
    exit 1
}

# 4. Execute Installer
Write-Host "Starting remote installation..."
# Use Windows native ssh with -t for interactivity
ssh -t "$PiUser@$($PiIp)" "cd ~/86box_install && chmod +x install_on_pi.sh && sudo ./install_on_pi.sh"

# 5. Cleanup
Write-Host "Cleaning up local bundle..."
Remove-Item -Recurse -Force $TempDir

Write-Host "==========================================" -ForegroundColor Green
Write-Host "      DEPLOYMENT SUCCESSFUL               " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Your 86Box appliance is now installed on the Pi."
Write-Host "Login via SSH/VNC and enjoy!"
