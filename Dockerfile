# ==========================================
# FINAL SELF-HEALING RENDER VM
# ==========================================
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080 \
    HOME=/home/ubuntu \
    DEBIAN_FRONTEND=noninteractive

# 2. Fix GPG Error and Install dependencies
RUN rm -f /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y curl ca-certificates websockify novnc && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
EXPOSE 6080

# 4. ROBUST ENTRYPOINT
RUN echo '#!/bin/bash\n\
echo "🚀 Cleaning environment..."\n\
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*\n\
\n\
echo "🚀 Starting Alist..."\n\
/opt/alist/alist server &\n\
\n\
echo "🖥️ Starting Xvfb..."\n\
Xvfb :1 -screen 0 1920x1080x16 &\n\
export DISPLAY=:1\n\
sleep 5\n\
\n\
echo "🖥️ Starting Desktop..."\n\
lxsession -s LXDE -e LXDE &\n\
\n\
echo "🌐 Starting Web VNC..."\n\
# Dynamically locate the novnc directory\n\
NOVNC_WEB_DIR=$(find /usr/share -name vnc_lite.html | head -n 1 | sed "s/\/vnc_lite.html//")\n\
echo "✅ Found noVNC web files at: $NOVNC_WEB_DIR"\n\
\n\
x11vnc -display :1 -nopw -listen localhost -xkb -forever &\n\
\n\
websockify --web "$NOVNC_WEB_DIR" 6080 localhost:5900' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
