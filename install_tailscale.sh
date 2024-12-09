#!/bin/bash
mkdir /userdata/temp
cd /userdata/temp
wget https://pkgs.tailscale.com/stable/tailscale_1.76.1_amd64.tgz
tar -xf tailscale_1.76.1_amd64.tgz
cd tailscale_1.76.1_amd64
mkdir /userdata/tailscale
mv systemd /userdata/tailscale/systemd
mv tailscale /userdata/tailscale/tailscale
mv tailscaled /userdata/tailscale/tailscaled
cd /userdata
rm -rf temp
mkdir /userdata/system/services
touch /userdata/system/services/tailscale
cat <<EOF > /userdata/system/services/tailscale
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
EOF

/userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &/userdata/tailscale/tailscale up
wait

batocera-services list
batocera-services enable tailscale
reboot
