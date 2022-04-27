#!/bin/bash
case $EXECUTOR in
  macos)
    tailscale down
    ;;
  linux)
    sudo tailscale down
    ;;
  windows)
    /c/PROGRA~2/"Tailscale IPN"/tailscale.exe down
    ;;
esac