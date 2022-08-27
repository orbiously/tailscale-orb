#!/bin/bash

if [ -z "${!PARAM_TS_AUTH_KEY}" ]; then 
    printf "The environment variable that is supposed to contain the Tailscale authentication key is not set.\n"
    echo "- Did you store the Tailscale authentication key in an evironment variable named ${PARAM_TS_AUTH_KEY}?"
    echo "- In case you stored the Tailscale authentication key in an environment variable with different name than TS_AUTH_KEY, did you specify that custom name via the ts-auth-key parameter?"
    echo "- Is the environment variable delared in an organization context? If so, did you specify the context name in the workflow?"
    exit 1
fi

case $EXECUTOR in

  docker)
    tmux new-session -d -s "TempSession" tailscaled --tun=userspace-networking --outbound-http-proxy-listen=localhost:1054 --socks5-server=localhost:1055 --socket=/tmp/tailscaled.sock 1>/dev/null 2>/tmp/tailscaled.log

    # if (! tailscale --socket=/tmp/tailscaled.sock up --authkey="${!PARAM_TS_AUTH_KEY}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes); then
    #   printf "\nEither:\n - The Tailscale auth key you're using is invalid\n or\n - The \"Device Authorization > Manually authorize new devices\" Tailnet setting is enabled and the Tailscale auth key is NOT pre-authorized (https://tailscale.com/kb/1099/device-authorization/)"
    #   exit 1
    # fi    

    tailscale_connect=("tailscale" "--socket=/tmp/tailscaled.sock" "up" "--authkey=${!PARAM_TS_AUTH_KEY}" "--hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" "--accept-routes")  

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
    
    # if (! tailscale up --authkey="${!PARAM_TS_AUTH_KEY}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes); then
    #   printf "\nEither:\n - The Tailscale auth key you're using is invalid\n or\n - The \"Device Authorization > Manually authorize new devices\" Tailnet setting is enabled and the Tailscale auth key is NOT pre-authorized (https://tailscale.com/kb/1099/device-authorization/)"
    #   exit 1
    # fi
    
    tailscale_connect=("tailscale up --authkey=${!PARAM_TS_AUTH_KEY} --hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM --accept-routes")

    tailscale_status=(tailscale status)
    tailscale_ping=(tailscale ping)
    ;;
  linux)
    # if (! sudo tailscale up --authkey="${!PARAM_TS_AUTH_KEY}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes); then
    #   printf "\nEither:\n - The Tailscale auth key you're using is invalid\n or\n - The \"Device Authorization > Manually authorize new devices\" Tailnet setting is enabled and the Tailscale auth key is NOT pre-authorized (https://tailscale.com/kb/1099/device-authorization/)"
    #   exit 1
    # fi
    
    tailscale_connect=("sudo tailscale" "up" "--authkey=${!PARAM_TS_AUTH_KEY}" "--hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" "--accept-routes")

    tailscale_status=(tailscale status)
    tailscale_ping=(tailscale ping)
    ;;
  windows)
    # if (! /c/PROGRA~2/"Tailscale IPN"/tailscale.exe up --authkey="${!PARAM_TS_AUTH_KEY}" --hostname="$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes); then
    #   printf "\nEither:\n - The Tailscale auth key you're using is invalid\n or\n - The \"Device Authorization > Manually authorize new devices\" Tailnet setting is enabled and the Tailscale auth key is NOT pre-authorized (https://tailscale.com/kb/1099/device-authorization/)"
    #   exit 1
    # fi

    tailscale_connect=("/c/PROGRA~2/'Tailscale IPN'/tailscale.exe up --authkey=${!PARAM_TS_AUTH_KEY} --hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM --accept-routes")

    tailscale_status=(/c/PROGRA~2/"Tailscale IPN"/tailscale.exe status)
    tailscale_ping=(/c/PROGRA~2/"Tailscale IPN"/tailscale.exe ping)
    ;;
esac

if (! "${tailscale_connect[@]}" ); then
  printf "\nEither:\n - The Tailscale auth key you're using is invalid\n or\n - The \"Device Authorization > Manually authorize new devices\" Tailnet setting is enabled and the Tailscale auth key is NOT pre-authorized (https://tailscale.com/kb/1099/device-authorization/)"
  exit 1
fi

if ( "${tailscale_status[@]}" | grep jumper | grep "offline" ); then
  printf "\nRemote Tailscale host is offline\n"
  printf "\nMake sure Tailscale is started on the remote host before attempting to run this job again\n"
  exit 1
fi

"${tailscale_ping[@]}" "$PARAM_TS_DST_HOST"
