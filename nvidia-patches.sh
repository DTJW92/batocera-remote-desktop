#!/bin/bash

# Halt on error
set -euo pipefail

# Detect Nvidia GPU and apply patches
if lspci | grep -i "nvidia" > /dev/null; then
    echo "Nvidia GPU detected. Applying patches..."
    
    # Extract the Nvidia driver version from the log
    driver_version=$(grep "Using NVIDIA Production driver" /userdata/system/logs/nvidia.log | awk -F " - " '{print $2}' | tr -d '[:space:]')
    
    # Check if driver version was found
    if [[ -z "$driver_version" ]]; then
        echo "Error: Could not detect Nvidia driver version. Please specify manually with -d VERSION."
        exit 1
    fi

    echo "Detected Nvidia driver version: $driver_version"
    
    # Apply the patches with the detected driver version
    curl -L "https://raw.githubusercontent.com/keylase/nvidia-patch/master/patch.sh" | bash -s -- -d "$driver_version"
    curl -L "https://raw.githubusercontent.com/keylase/nvidia-patch/master/patch-fbc.sh" | bash -s -- -d "$driver_version"
    
else
    # Either no Nvidia GPU or AMD GPU detected
    if lspci | grep -i "amd" > /dev/null; then
        echo "AMD GPU detected. Skipping Nvidia patches."
    else
        echo "No supported GPU detected. Skipping patches."
    fi
fi

exec
