#!/usr/bin/env bash
# ==============================================================================
# TOSHIBA e-STUDIO 257 Driver Package Fetcher
# Downloads and extracts BW_Unix_Linux.zip next to install.sh, so the
# original install.sh can be run afterward without modification.
# ==============================================================================

set -e

DRIVER_ZIP_URL="https://business.toshiba.com/downloads/KB/f1Ulds/21842/BW_Unix_Linux.zip"
DRIVER_ZIP_NAME="BW_Unix_Linux.zip"
DRIVER_DIR="BW_Unix_Linux"
# The zip only contains this inner tar; install.sh expects it already extracted
INNER_TAR="${DRIVER_DIR}/CUPS/Usa/2-sided_default/TOSHIBA_MonoMFP_CUPS.tar"
INNER_TAR_DIR="${DRIVER_DIR}/CUPS/Usa/2-sided_default"
EXPECTED_FILTER="${DRIVER_DIR}/CUPS/Usa/2-sided_default/usr/lib/cups/filter/est856_Authentication"

echo "=========================================================="
echo " Toshiba Driver Package Fetcher"
echo "=========================================================="

if [ -f "$EXPECTED_FILTER" ]; then
    echo "[+] Driver already extracted and unpacked, nothing to do."
    echo "    You can now run: sudo ./install.sh"
    exit 0
fi

if [ ! -f "$DRIVER_ZIP_NAME" ]; then
    echo "[+] Downloading driver package from Toshiba..."
    if command -v curl >/dev/null 2>&1; then
        curl -fL --progress-bar -o "$DRIVER_ZIP_NAME" "$DRIVER_ZIP_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$DRIVER_ZIP_NAME" "$DRIVER_ZIP_URL"
    else
        echo "[-] Error: Neither curl nor wget is available to download the package."
        echo "    Install one of them, or manually download:"
        echo "    $DRIVER_ZIP_URL"
        exit 1
    fi
else
    echo "[+] Found existing ${DRIVER_ZIP_NAME}, skipping download."
fi

if [ ! -s "$DRIVER_ZIP_NAME" ]; then
    echo "[-] Error: Download failed or produced an empty file."
    exit 1
fi

echo "[+] Extracting ${DRIVER_ZIP_NAME}..."
if command -v unzip >/dev/null 2>&1; then
    unzip -o -q "$DRIVER_ZIP_NAME"
else
    echo "[-] Error: 'unzip' is not installed. Install it with your package manager"
    echo "    (e.g. sudo apt install unzip) and re-run this script."
    exit 1
fi

# The zip only unpacks down to TOSHIBA_MonoMFP_CUPS.tar; install.sh needs its
# contents (usr/lib/cups/filter/..., usr/share/cups/model/Toshiba/...) as loose
# files, so extract that inner tar in place.
if [ ! -f "$INNER_TAR" ]; then
    echo "[-] Error: expected inner archive not found at:"
    echo "      $INNER_TAR"
    echo "    Toshiba may have changed the package layout. Contents found instead:"
    find "$DRIVER_DIR" -maxdepth 5 -type f
    exit 1
fi

echo "[+] Extracting inner archive TOSHIBA_MonoMFP_CUPS.tar..."
tar -xf "$INNER_TAR" -C "$INNER_TAR_DIR"

if [ ! -f "$EXPECTED_FILTER" ]; then
    echo "[-] Error: extraction finished but expected file is still missing:"
    echo "      $EXPECTED_FILTER"
    echo "    Actual contents of ${INNER_TAR_DIR}:"
    find "$INNER_TAR_DIR" -maxdepth 5
    echo "    install.sh's SRC_FILTER/SRC_GZ_PPD paths may need updating to match."
    exit 1
fi

echo "=========================================================="
echo "[+] Driver package ready in ./${DRIVER_DIR}"
echo "    You can now run: sudo ./install.sh"
echo "=========================================================="
