#!/bin/bash
set -o nounset

case $EXECUTOR in

  docker)
    tailscale --socket=/tmp/tailscaled.sock up --authkey="${!TS_AUTH_KEY}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes

    tailscale_status=("tailscale" "--socket=/tmp/tailscaled.sock" "status")                
    
    tailscale_ping=("tailscale" "--socket=/tmp/tailscaled.sock" "ping")
    ;;
  macos)
cat << EOF | sudo tee /Library/LaunchDaemons/com.tailscale.tailscaled.plist 1>/dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
  <key>Label</key>
  <string>com.tailscale.tailscaled</string>
  <key>Program</key>
    <string>/usr/local/bin/tailscaled</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/tailscaled</string>
  </array>
  <key>RunAtLoad</key>
    <false/>
  </dict>
</plist>
EOF

    sudo launchctl load /Library/LaunchDaemons/com.tailscale.tailscaled.plist
    sudo launchctl start com.tailscale.tailscaled
    
    tailscale up --authkey "${!TS_AUTH_KEY}}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes
    tailscale_status=(tailscale status)
    tailscale_ping=(tailscale ping)
    ;;
  linux)
    sudo tailscale up --authkey="${!TS_AUTH_KEY}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes
    tailscale_status=(tailscale status)
    tailscale_ping=(tailscale ping)
    ;;
  windows)
    /c/PROGRA~2/"Tailscale IPN"/tailscale.exe up --authkey="${!TS_AUTH_KEY}}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes
    tailscale_status=(/c/PROGRA~2/"Tailscale IPN"/tailscale.exe status)
    tailscale_ping=(/c/PROGRA~2/"Tailscale IPN"/tailscale.exe ping)
    ;;
esac

if ( "${tailscale_status[@]}"  | grep jumper | grep "offline" ); then
  printf "\nRemote Tailscale host is offline\n"
  printf "\nMake sure Tailscale is started on the remote host before attempting to run this job again\n"
  printf "\nFailing the build\n"
  exit 1
fi

"${tailscale_ping[@]}" "$TS_DST_HOST"
