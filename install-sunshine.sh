# Step 1: Install Sunshine
echo "Installing Sunshine..."
mkdir -p /userdata/system
wget -O /userdata/system/sunshine.AppImage  https://github.com/DTJW92/Remote-desktop/raw/main/sunshine.AppImage

chmod a+x /userdata/system/sunshine.AppImage

# Create a persistent configuration directory
mkdir -p /userdata/system/sunshine-config
mkdir -p /userdata/system/logs

# Configure Sunshine as a service
echo "Configuring Sunshine service..."
mkdir -p /userdata/system/services
cat << 'EOF' > /userdata/system/services/sunshine
#!/bin/bash
export $(cat /proc/1/environ | tr '\0' '\n')
export DISPLAY=:0.0

if [[ "$1" != "start" ]]; then
  exit 0
fi

# Create persistent directory for Sunshine config (if it doesn't exist)
mkdir -p /userdata/system/sunshine-config/sunshine

# Check if Sunshine config exists (after the first run) and move it to persistent storage
if [ -d ~/.config/sunshine ]; then
  mv ~/.config/sunshine /userdata/system/sunshine-config/sunshine
fi

if [ ! -L ~/.config/sunshine ]; then
  ln -s /userdata/system/sunshine-config/sunshine ~/.config/sunshine
fi

# Run Sunshine
cd /userdata/system
./sunshine.AppImage > /userdata/system/logs/sunshine.log 2>&1 &

EOF

chmod +x /userdata/system/services/sunshine

# Enable and start the Sunshine service
batocera-services enable sunshine
batocera-services start sunshine

echo "Installation complete! Please head to https://YOUR-MACHINE-IP:47990 to pair Sunshine with Moonlight."
