#!/bin/bash
set -u

# Intune Linux custom compliance discovery script
# Checks whether Microsoft Defender for Endpoint (mdatp) is installed
# and whether the mdatp service is currently active.
# Runs in user context; no elevation is required.

installed=false
running=false

# Detect installation.
# Primary check for Ubuntu/Debian package-based installation.
if command -v dpkg-query >/dev/null 2>&1; then
    if dpkg-query -W -f='${Status}' mdatp 2>/dev/null | grep -q '^install ok installed$'; then
        installed=true
    fi
fi

# Fallbacks in case dpkg metadata is unavailable but binaries/paths exist.
if [ "$installed" = false ]; then
    if command -v mdatp >/dev/null 2>&1 || [ -x "/opt/microsoft/mdatp/sbin/wdavdaemon" ] || [ -d "/opt/microsoft/mdatp" ]; then
        installed=true
    fi
fi

# Detect running state only if Defender appears to be installed.
if [ "$installed" = true ]; then
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet mdatp.service 2>/dev/null || systemctl is-active --quiet mdatp 2>/dev/null; then
            running=true
        fi
    fi

    # Fallback if systemctl is unavailable or returns no active state.
    if [ "$running" = false ] && command -v pgrep >/dev/null 2>&1; then
        if pgrep -x wdavdaemon >/dev/null 2>&1; then
            running=true
        fi
    fi
fi

printf '{"DefenderInstalled":%s,"DefenderRunning":%s}\n' "$installed" "$running"