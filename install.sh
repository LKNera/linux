#!/usr/bin/env bash

# ==============================================================================
# TOSHIBA e-STUDIO 257 Driver Backend Deployer (Manual Web Interface Setup)
# Targets: Linux x86_64 distributions (CUPS)
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# Relative Source Paths (Validated against your system's tree output)
SRC_FILTER="BW_Unix_Linux/CUPS/Usa/2-sided_default/usr/lib/cups/filter/est856_Authentication"
SRC_GZ_PPD="BW_Unix_Linux/CUPS/Usa/2-sided_default/usr/share/cups/model/Toshiba/TOSHIBA_MonoMFP_CUPS.gz"

# System Destination Paths
SYS_FILTER_DIR="/usr/lib/cups/filter"
SYS_MODEL_DIR="/usr/share/cups/model/Toshiba"
FINAL_PPD_FILE="${SYS_MODEL_DIR}/TOSHIBA_MonoMFP_CUPS.ppd"

# Ensure script is executed with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: This script must be run with sudo privileges."
    echo "    Usage: sudo ./deploy_toshiba_backend.sh"
    exit 1
fi

echo "=========================================================="
echo " Deploying Toshiba Driver Core Components..."
echo "=========================================================="

# 1. Source File Integrity Verification
if [ ! -f "$SRC_FILTER" ] || [ ! -f "$SRC_GZ_PPD" ]; then
    echo "[-] Error: Source files missing! Ensure you run this script inside"
    echo "    your 'Descargas' directory directly adjacent to 'BW_Unix_Linux'."
    exit 1
fi

# 2. Deploy CUPS Authentication Filter Binary
echo "[+] Copying filter binary to CUPS directory..."
cp "$SRC_FILTER" "${SYS_FILTER_DIR}/"
chmod 755 "${SYS_FILTER_DIR}/est856_Authentication"
chown root:root "${SYS_FILTER_DIR}/est856_Authentication"

# 3. Deploy and Decompress the PPD Profile
echo "[+] Processing and extracting PPD driver profile..."
mkdir -p "$SYS_MODEL_DIR"
cp "$SRC_GZ_PPD" "${SYS_MODEL_DIR}/"

if [ -f "${SYS_MODEL_DIR}/TOSHIBA_MonoMFP_CUPS.gz" ]; then
    gunzip -f "${SYS_MODEL_DIR}/TOSHIBA_MonoMFP_CUPS.gz"
    mv -f "${SYS_MODEL_DIR}/TOSHIBA_MonoMFP_CUPS" "$FINAL_PPD_FILE"
fi
chmod 644 "$FINAL_PPD_FILE"
chown root:root "$FINAL_PPD_FILE"

# 4. Cycle CUPS daemon to load the new filter/PPD path
echo "[+] Reloading print engine daemon..."
if systemctl is-active --quiet cups; then
    systemctl restart cups
elif systemctl is-active --quiet cupsd; then
    systemctl restart cupsd
else
    service cups restart || true
fi

echo "=========================================================="
echo "[+] DEPLOYMENT COMPLETE!"
echo "    Filter installed: ${SYS_FILTER_DIR}/est856_Authentication"
echo "    PPD file unzipped: ${FINAL_PPD_FILE}"
echo "=========================================================="
echo "You can now open http://localhost:631 in your browser,"
echo "add your printer, and select or browse to this custom PPD."
echo "=========================================================="
