# Batocera RDP Setup with Tailscale and Sunshine

This script automates the installation and configuration of Tailscale (for secure remote access) and Sunshine (for game streaming via Moonlight) on a Batocera system.

## Requirements
- Batocera OS
- An active internet connection
- A compatible machine (x86_64 architecture)

## Installation Instructions

1. **Run the Script**:
   To install and configure both Tailscale and Sunshine, use the following command in your Batocera terminal:

     `curl -L https://bit.ly/BatoceraRDP | bash`
   
    To install just Sunshine, without Tailscale, you can use the following command;
   
      `curl -L https://bit.ly/BatoceraSunshine | bash`

It is recommended to do this via SSH, since you will need to manually authorise adding Tailscale to your account, and set up Sunshine (via Web UI) and with Moonlight.

## You will need to go to the link provided by the Tailscale installer to authorise adding Tailscale to your acocunt, the install script will not proceed without it! 

### Make sure you enable the Subnet Routes within the dashboard!

## You will need to go to `https://192.168.1.##:47990` to set up credentials for Sunshine and link it with Moonlight (via Pin)!

Local IP will still work, Tailscale needs to be installed for the device to access your Batocera system remotely. You can find the relevant IP address in the Tailscale dashboard.

Any issues, you can reach out via the Batocera Nation discord https://discord.gg/XNxWHc6K4P
