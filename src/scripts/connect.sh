#!/bin/bash
case $EXECUTOR in
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
    
    tailscale up --authkey "$TS_KEY" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes
    tailscale ping "$TS_DST_HOST"
    ;;
  linux)
    sudo tailscale up --authkey="TS_KEY" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes
    tailscale ping "$TS_DST_HOST"
    ;;
  windows)
    /c/PROGRA~2/"Tailscale IPN"/tailscale.exe up --authkey="TS_KEY" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes
    /c/PROGRA~2/"Tailscale IPN"/tailscale.exe ping "$TS_DST_HOST"
    ;;
esac