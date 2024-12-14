#!/bin/bash

# Halt on error
set -euo pipefail

# Detect Nvidia GPU and apply patches
if lspci | grep -i "nvidia" > /dev/null; then
    echo "Nvidia GPU detected. Applying patches..."
    curl -L https://raw.githubusercontent.com/keylase/nvidia-patch/master/patch.sh | bash
    curl -L https://raw.githubusercontent.com/keylase/nvidia-patch/master/patch-fbc.sh | bash
elif lspci | grep -i "amd" > /dev/null; then
    echo "AMD GPU detected. Skipping Nvidia patches."
    # Add AMD-specific configuration here, if needed
else
    echo "No supported GPU detected. Skipping patches."
fi

exec
