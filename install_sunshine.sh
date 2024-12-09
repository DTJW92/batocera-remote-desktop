#!/bin/bash

# Ensure Flathub is added as a Flatpak remote repository
if ! flatpak remotes | grep -q "flathub"; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Sunshine via Flatpak if not already installed
if ! flatpak list | grep -q "dev.lizardbyte.app.Sunshine"; then
    echo "Installing Sunshine via Flatpak..."
    flatpak install -y --noninteractive flathub dev.lizardbyte.app.Sunshine
else
    echo "Sunshine is already installed."
fi

# Add Sunshine service to batocera.conf
echo "Enabling Sunshine service in batocera.conf..."
if ! grep -q "system.sunshine.enabled" /userdata/system/batocera.conf; then
    echo "system.sunshine.enabled=1" >> /userdata/system/batocera.conf
else
    sed -i 's/system.sunshine.enabled=.*/system.sunshine.enabled=1/' /userdata/system/batocera.conf
fi

# Ensure logs directory exists
mkdir -p /userdata/system/logs

# Create Sunshine service script in /userdata/system/services
echo "Creating Sunshine service script..."
cat << 'EOF' > /userdata/system/services/sunshine
#!/bin/bash

# Batocera service script for Sunshine
case "$1" in
    start)
        # Set the PULSE_SERVER environment variable dynamically and start Sunshine in the background
        export PULSE_SERVER="unix:$(pactl info | awk '/Server String/{print $3}')"
        flatpak run dev.lizardbyte.app.Sunshine > /userdata/system/logs/sunshine.log 2>&1 &
        ;;
    stop)
        # Kill the Sunshine process
        pkill -f "flatpak run dev.lizardbyte.app.Sunshine"
        ;;
    restart)
        $0 stop
        $0 start
        ;;
esac
EOF

# Make the Sunshine service script executable
chmod +x /userdata/system/services/sunshine

# Display informational message with instructions
echo "Sunshine has been installed and set up as a service.\n\nPlease enable it in the services menu within system settings.\n\nAccess Sunshine web ui at https://your_batocera_ip:47990\n\nLogs can be found at /userdata/system/logs/sunshine.log" 12 50

