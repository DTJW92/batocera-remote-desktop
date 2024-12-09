#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# Remove Sunshine Flatpak installation
if flatpak info dev.lizardbyte.app.Sunshine > /dev/null 2>&1; then
    echo "Uninstalling Sunshine via Flatpak..."
    flatpak uninstall -y --noninteractive dev.lizardbyte.app.Sunshine || {
        echo "Failed to uninstall Sunshine."
        exit 1
    }
else
    echo "Sunshine is not installed."
fi

# Remove Sunshine configuration from batocera.conf
echo "Removing Sunshine service configuration from batocera.conf..."
if grep -q "system.sunshine.enabled" /userdata/system/batocera.conf; then
    sed -i '/system.sunshine.enabled/d' /userdata/system/batocera.conf
    echo "Removed Sunshine configuration."
else
    echo "Sunshine configuration not found in batocera.conf."
fi

# Remove Sunshine service script
SERVICE_SCRIPT="/userdata/system/services/sunshine"
if [ -f "$SERVICE_SCRIPT" ]; then
    echo "Removing Sunshine service script..."
    rm -f "$SERVICE_SCRIPT"
    echo "Sunshine service script removed."
else
    echo "Sunshine service script not found."
fi

# Remove Sunshine logs
LOGS_DIR="/userdata/system/logs"
LOG_FILE="$LOGS_DIR/sunshine.log"
if [ -f "$LOG_FILE" ]; then
    echo "Removing Sunshine log file..."
    rm -f "$LOG_FILE"
    echo "Sunshine log file removed."
else
    echo "Sunshine log file not found."
fi

# Ensure the logs directory is retained but empty (optional)
if [ -d "$LOGS_DIR" ]; then
    echo "Ensuring logs directory is clean..."
    rm -f "$LOGS_DIR/"*
fi

# Display completion message
echo -e "\nSunshine has been uninstalled and related configurations removed."
