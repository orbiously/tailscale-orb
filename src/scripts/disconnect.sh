#!/bin/bash
echo "Disconnecting from Tailscale..."
case $EXECUTOR in
  macos)
    tailscale down
    ;;
  linux|docker)
    sudo tailscale down
    ;;
  windows)
    /c/PROGRA~1/Tailscale/tailscale.exe down
    ;;
esac
