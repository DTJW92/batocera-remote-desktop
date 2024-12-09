#!/bin/bash

echo "Starting Tailscale uninstallation..."

# Stop the Tailscale service if it's running
echo "Stopping the Tailscale service..."
pkill -f tailscaled
pkill -f tailscale

# Remove Tailscale binaries and directories
TAILSCALE_DIR="/userdata/tailscale"
if [ -d "$TAILSCALE_DIR" ]; then
    echo "Removing Tailscale directory: $TAILSCALE_DIR"
    rm -rf "$TAILSCALE_DIR"
else
    echo "Tailscale directory not found: $TAILSCALE_DIR"
fi

# Remove the Tailscale service file
SERVICE_FILE="/userdata/system/services/tailscale"
if [ -f "$SERVICE_FILE" ]; then
    echo "Removing Tailscale service file: $SERVICE_FILE"
    rm -f "$SERVICE_FILE"
else
    echo "Tailscale service file not found: $SERVICE_FILE"
fi

# Disable the Tailscale service
echo "Disabling Tailscale service..."
batocera-services disable tailscale 2>/dev/null || echo "batocera-services command not available or failed."

# Restore original sysctl settings if a backup exists
SYSCTL_BACKUP="/etc/sysctl.conf.bak"
if [ -f "$SYSCTL_BACKUP" ]; then
    echo "Restoring sysctl settings from backup..."
    mv "$SYSCTL_BACKUP" /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
else
    echo "Sysctl backup not found. Skipping restore."
fi

# Clean up TUN device if created
if [ -c /dev/net/tun ]; then
    echo "Removing TUN device..."
    rm -f /dev/net/tun
    rmdir /dev/net 2>/dev/null || echo "Failed to remove /dev/net directory."
fi

echo "Tailscale uninstallation complete."
