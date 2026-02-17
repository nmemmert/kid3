#!/usr/bin/env bash
set -euo pipefail

DISPLAY=${DISPLAY:-:1}
VNC_PORT=${VNC_PORT:-5900}
NOVNC_PORT=${NOVNC_PORT:-5879}
SCREEN=${SCREEN:-1280x720x24}

mkdir -p /tmp/runtime-kid3user

Xvfb "$DISPLAY" -screen 0 "$SCREEN" -ac +extension GLX +render -noreset &
fluxbox >/dev/null 2>&1 &

if [[ -n "${VNC_PASSWORD:-}" ]]; then
    mkdir -p /home/kid3user/.vnc
    x11vnc -storepasswd "$VNC_PASSWORD" /home/kid3user/.vnc/passwd
    X11VNC_ARGS="-rfbauth /home/kid3user/.vnc/passwd"
else
    X11VNC_ARGS="-nopw"
fi

x11vnc -display "$DISPLAY" -forever -shared -rfbport "$VNC_PORT" $X11VNC_ARGS >/dev/null 2>&1 &
/usr/share/novnc/utils/launch.sh --vnc localhost:"$VNC_PORT" --listen "$NOVNC_PORT" >/dev/null 2>&1 &

exec kid3-qt
