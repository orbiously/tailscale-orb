#!/bin/bash

if [ -z "${!PARAM_TS_AUTH_KEY}" ]; then 
    printf "The environment variable that is supposed to contain the Tailscale auth key is not set or accessible:\n"
    if [ "${PARAM_TS_AUTH_KEY}" != "TS_AUTH_KEY" ]; then
      echo "- Make sure to store the Tailscale auth key in an environment variable named ${PARAM_TS_AUTH_KEY}."
    else
      echo "- In case you stored the Tailscale auth key in an environment variable with a different name than TS_AUTH_KEY, you need to specify that custom name via the \"ts-auth-key parameter\"."
    fi
    echo "- If the environment variable ${PARAM_TS_AUTH_KEY} is delared in an organization context, the context name must be referenced in the workflow."
    exit 1
fi

case $EXECUTOR in

  docker)
    tmux new-session -d -s "TempSession" sudo tailscaled --tun=userspace-networking --outbound-http-proxy-listen=localhost:1054 --socks5-server=localhost:1055 1>/dev/null 2>/tmp/tailscaled.log

    tailscale_connect=(sudo tailscale up "--authkey=${!PARAM_TS_AUTH_KEY}" "--hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" "--accept-routes")

    echo "export ALL_PROXY=socks5h://localhost:1055/" >> $BASH_ENV
    echo "export HTTP_PROXY=http://localhost:1054/" >> $BASH_ENV
    echo "export HTTPS_PROXY=http://localhost:1054/" >> $BASH_ENV
    echo "export http_proxy=http://localhost:1054/" >> $BASH_ENV
    echo "export https_proxy=http://localhost:1054/" >> $BASH_ENV

    tailscale_status=(tailscale status)                
    
    tailscale_ping=(tailscale ping --c "$PARAM_TS_MAX_PINGS")
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

    while true; do
      status=$(sudo launchctl list com.tailscale.tailscaled | awk '{print $1}')
      if [ "$status" != "-" ]; then
        break
      fi
      sleep 1
    done


    tailscale_connect=(tailscale up "--authkey=${!PARAM_TS_AUTH_KEY}" "--hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes)

    tailscale_status=(tailscale status)
    tailscale_ping=(tailscale ping --c "$PARAM_TS_MAX_PINGS")
    ;;
  linux)
    tailscale_connect=(sudo tailscale up "--authkey=${!PARAM_TS_AUTH_KEY}" "--hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes)

    tailscale_status=(tailscale status)
    tailscale_ping=(tailscale ping --c "$PARAM_TS_MAX_PINGS")
    ;;
  windows)
    tailscale_connect=(/c/PROGRA~1/Tailscale/tailscale.exe up "--authkey=${!PARAM_TS_AUTH_KEY}" "--hostname=$CIRCLE_PROJECT_USERNAME-$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM" --accept-routes)

    tailscale_status=(/c/PROGRA~1/Tailscale/tailscale.exe status)
    tailscale_ping=(/c/PROGRA~1/Tailscale/tailscale.exe ping --c "$PARAM_TS_MAX_PINGS")
    ;;
esac


if (! "${tailscale_connect[@]}" ); then
  printf "\nEither:\n - The Tailscale auth key stored in the %s environment variable is invalid\n or\n - The \"Device Authorization > Manually authorize new devices\" Tailnet setting is enabled and the Tailscale auth key is NOT pre-authorized (https://tailscale.com/kb/1099/device-authorization/)" "${PARAM_TS_AUTH_KEY}"
  exit 1
fi

printf "Connected to Tailscale.\n"

printf "Attempting to establish direct link with host \"%s\"...\n\n" "$PARAM_TS_DST_HOST"

if ( "${tailscale_status[@]}" | grep "$PARAM_TS_DST_HOST"  > /dev/null); then
  if ( "${tailscale_status[@]}" | grep "$PARAM_TS_DST_HOST" | grep "offline" ); then
    printf "\nRemote Tailscale host %s is offline.\n" "$PARAM_TS_DST_HOST"
    printf "\nMake sure Tailscale is started on the remote host before attempting to run this job again\n"
    exit 1
  fi
else
  printf "\nThere is no machine with hostname/IP matching \"%s\" in your Tailnet\n" "$PARAM_TS_DST_HOST"
  printf "Make sure to reference the correct Tailscale hostname/IP in the \"ts-dst-host\" parameter\n"
  exit 1
fi
  
"${tailscale_ping[@]}" "$PARAM_TS_DST_HOST"
