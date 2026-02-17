# Kid3 Audio Tagger Container (GUI + CLI)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    kid3-qt \
    kid3-cli \
    dbus-x11 \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    websockify \
    libx11-6 \
    libxcb1 \
    libxkbcommon0 \
    libgl1 \
    libglib2.0-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf vnc.html /usr/share/novnc/index.html

RUN useradd -m -s /bin/bash kid3user \
    && mkdir -p /tmp/runtime-kid3user \
    && chown -R kid3user:kid3user /tmp/runtime-kid3user

COPY start-kid3-vnc.sh /usr/local/bin/start-kid3-vnc.sh
RUN chmod +x /usr/local/bin/start-kid3-vnc.sh

ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
ENV XDG_RUNTIME_DIR=/tmp/runtime-kid3user

USER kid3user
WORKDIR /home/kid3user

CMD ["kid3-qt"]
