#!/usr/bin/env bash
set -euo pipefail

DISPLAY=${DISPLAY:-:1}
VNC_PORT=${VNC_PORT:-5900}
NOVNC_PORT=${NOVNC_PORT:-5879}
SCREEN=${SCREEN:-1280x720x24}

mkdir -p /tmp/runtime-kid3user

# Start Xvfb
Xvfb "$DISPLAY" -screen 0 "$SCREEN" -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for X server to be ready
sleep 3

# Start window manager
fluxbox >/dev/null 2>&1 &

# Configure VNC password if provided
if [[ -n "${VNC_PASSWORD:-}" ]]; then
    mkdir -p /home/kid3user/.vnc
    x11vnc -storepasswd "$VNC_PASSWORD" /home/kid3user/.vnc/passwd
    X11VNC_ARGS="-rfbauth /home/kid3user/.vnc/passwd"
else
    X11VNC_ARGS="-nopw"
fi

# Start VNC server
x11vnc -display "$DISPLAY" -forever -shared -rfbport "$VNC_PORT" $X11VNC_ARGS >/dev/null 2>&1 &

# Start noVNC web server
websockify --web /usr/share/novnc "$NOVNC_PORT" localhost:"$VNC_PORT" >/dev/null 2>&1 &

# Wait a moment for services to initialize
sleep 2

# Launch Kid3
exec kid3-qt
