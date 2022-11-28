#!/usr/bin/env bash
#
# https://stackoverflow.com/questions/12050021/how-to-make-xvfb-display-visible
#
# -passwd tribler: can't be arsed with setting up /root/.vnc/passwd
# -shared: required for mac vncviewer

cd $(dirname $0)

# Do not use 32bpp
export DISPLAYSIZE=${DISPLAYSIZE:-"1200x900x24+32"}

# login with this password
export VNCPASSWORD=${VNCPASSWORD:-"tribler"}

export DISPLAY=:1

echo "--- starting Xvfb"
/usr/bin/Xvfb $DISPLAY -screen 0 "$DISPLAYSIZE" &
sleep 1

echo "--- starting fluxbox"
/usr/bin/fluxbox 2>/dev/null &
sleep 1

echo "--- starting x11vnc"
x11vnc -display $DISPLAY -bg -quiet \
  -usepw -passwd "$VNCPASSWORD" -shared -forever &
sleep 1

# Forward 20100 globally to localhost:222222
if [[ "$(which socat)" != "" ]]; then
  echo "--- starting socat bridge to $CORE_API_PORT -> 22222"
  # remap this port, so we can make a bridge
  export CORE_API_PORT=22222
  socat tcp-listen:20100,reuseaddr,fork tcp:localhost:22222 &
else
  echo "---! socat not found, NOT forwarding port $CORE_API_PORT"
fi

echo "--- starting tribler"
# detect log folder and logrotate application
if [[ -d $HOME/logs && "$(which rotatelogs)" != "" ]]; then
  echo "Tribler logs are being sent to $HOME/logs/tribler.log"
  /tribler/src/tribler.sh 2>&1 | rotatelogs -n 5 $HOME/logs/tribler.log 100M
else
  # just spam stdout, causing docker logs to balloon ;-)
  /tribler/src/tribler.sh
fi
