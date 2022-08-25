#!/bin/bash
printf "Executor is %s.\n" "$EXECUTOR"
case $EXECUTOR in
  linux|windows|macos)
    echo " > Nothing to do"
    ;;
  docker)
    echo " > Starting tailscaled"
    tailscaled --tun=userspace-networking --outbound-http-proxy-listen=localhost:1054 --socks5-server=localhost:1055 --socket=/tmp/tailscaled.sock 1>/dev/null 2>/tmp/tailscaled.log
    ;;
esac