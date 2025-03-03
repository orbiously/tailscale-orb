#!/bin/bash
install() {
    case $1 in
    [Ll]inux*)
      if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
        sudo apt-get update && sudo apt-get install -y tmux
        EXECUTOR=docker
      else
        EXECUTOR=linux
      fi
      printf "Installing Tailscale for Linux\n\n"
      sudo curl -fsSL https://tailscale.com/install.sh | sh
      ;;
    [Dd]arwin*)
      printf "Installing Tailscale for macOS\n\n"
      HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_AUTO_UPDATE=1 brew install tailscale
      EXECUTOR=macos
      ;;
    msys*|MSYS*|nt|win*)
      printf "Installing Tailscale for Windows\n\n"
      choco install tailscale -y
      EXECUTOR=windows
      ;;
    esac
}

install "$(uname)"

printf "\nTailscale for %s installed\n\n" "$PLATFORM"
printf "\nPublic IP is %s\n" "$(curl http://checkip.amazonaws.com)"
echo "export EXECUTOR=$EXECUTOR" >> $BASH_ENV
