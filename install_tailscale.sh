#!/bin/bash

# Step 1: Create the temp folder and navigate into it
mkdir -p /userdata/temp
cd /userdata/temp || { echo "Failed to change directory to /userdata/temp"; exit 1; }

# Step 2: Discover machine architecture
ARCH=$(uname -m)
case $ARCH in
    "x86_64")
        ARCH="amd64"
        ;;
    "i386"|"i686")
        ARCH="386"
        ;;
    "aarch64")
        ARCH="arm64"
        ;;
    "armv7l"|"armv6l")
        ARCH="arm"
        ;;
    "riscv64")
        ARCH="riscv64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Step 3: Retrieve the latest version dynamically
echo "Fetching the latest Tailscale version information..."
LATEST_VERSION=$(curl -s https://pkgs.tailscale.com/stable/ | grep -oP 'tailscale_\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to retrieve the latest Tailscale version."
    exit 1
fi

echo "Latest version found: $LATEST_VERSION"

DOWNLOAD_URL="https://pkgs.tailscale.com/stable/tailscale_${LATEST_VERSION}_${ARCH}.tgz"
echo "Downloading Tailscale from: $DOWNLOAD_URL"

# Step 3: Download the appropriate Tailscale package
wget "$DOWNLOAD_URL" -O tailscale.tgz

if [ $? -ne 0 ]; then
    echo "Failed to download Tailscale package."
    exit 1
fi

echo "Download completed: tailscale.tgz"

# Step 4: Unarchive the downloaded file
echo "Unarchiving the downloaded file..."
tar -xf tailscale.tgz

if [ $? -ne 0 ]; then
    echo "Failed to unarchive the Tailscale package."
    exit 1
fi

echo "Unarchiving completed."

# Step 5: Navigate into the extracted directory
EXTRACTED_DIR=$(tar -tf tailscale.tgz | head -n 1 | cut -f1 -d"/")
cd "$EXTRACTED_DIR" || { echo "Failed to change directory to $EXTRACTED_DIR"; exit 1; }

echo "Navigated to directory: $EXTRACTED_DIR"

# Step 6: Create the Tailscale directory
mkdir -p /userdata/tailscale
echo "Directory created: /userdata/tailscale"

# Step 7: Move files to the Tailscale directory
echo "Moving files to /userdata/tailscale..."
mv systemd /userdata/tailscale/systemd
mv tailscale /userdata/tailscale/tailscale
mv tailscaled /userdata/tailscale/tailscaled
echo "Files moved successfully."

# Step 8: Clean up the temporary directory
cd /userdata
rm -rf temp
echo "Temporary directory cleaned up."

# Step 9: Create the system services directory and prepare the Tailscale service file
mkdir -p /userdata/system/services
touch /userdata/system/services/tailscale
echo "Service file created at /userdata/system/services/tailscale."

# Step 10: Add contents to the tailscale service file
cat <<EOL > /userdata/system/services/tailscale
#!/bin/bash

if [[ "$1" != "start" ]]; then
  exit 0
fi

# Ensure /dev/net/tun exists
if [ ! -d /dev/net ]; then
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi

# Configure IP forwarding
sysctl_config="/etc/sysctl.conf"
temp_sysctl_config="/tmp/sysctl.conf"

# Backup existing sysctl.conf (if needed)
if [ -f "$sysctl_config" ]; then
  cp "$sysctl_config" "${sysctl_config}.bak"
fi

# Apply new configurations
cat <<EOL > "$temp_sysctl_config"
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOL

mv "$temp_sysctl_config" "$sysctl_config"
sysctl -p "$sysctl_config"

# Ensure Tailscale directories exist
tailscale_dir="/userdata/tailscale"
if [ ! -d "$tailscale_dir" ]; then
  mkdir -p "$tailscale_dir"
fi

# Start Tailscale daemon
"$tailscale_dir/tailscaled" -state "$tailscale_dir/state" > "$tailscale_dir/tailscaled.log" 2>&1 &

# Bring up Tailscale with specific options
"$tailscale_dir/tailscale" up --advertise-routes=192.168.1.0/24 --snat-subnet-routes=false --accept-routes
EOL

echo "Contents added to /userdata/system/services/tailscale."

# Step 12: Start the Tailscale daemon and bring up the service with the provided auth key
echo "Starting the Tailscale daemon..."
/userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &

echo "Bringing up Tailscale..."
/userdata/tailscale/tailscale up

# Step 13: Enable Tailscale service and reboot the system
echo "Enabling Tailscale service..."
batocera-services enable tailscale
batocera-services start tailscale

echo "Rebooting system..."
wait 5
reboot
