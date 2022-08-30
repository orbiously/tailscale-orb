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
    /c/PROGRA~2/"Tailscale IPN"/tailscale.exe down
    ;;
esac
