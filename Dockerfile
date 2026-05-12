# ==========================================
# FINAL STABLE UBUNTU DESKTOP FOR RENDER
# ==========================================
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080 \
    HOME=/home/ubuntu \
    DEBIAN_FRONTEND=noninteractive

# 2. Fix GPG Error and Install Alist
RUN rm -f /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
EXPOSE 6080

# 4. UNIVERSAL ENTRYPOINT
# Automatically finds noVNC and starts all services manually
RUN echo '#!/bin/bash\n\
echo "🚀 Starting Alist..."\n\
/opt/alist/alist server &\n\
\n\
echo "🖥️ Starting Xvfb and LXDE..."\n\
Xvfb :1 -screen 0 1920x1080x16 &\n\
export DISPLAY=:1\n\
sleep 2\n\
\n\
lxsession -s LXDE -e LXDE &\n\
\n\
echo "🌐 Starting Web VNC..."\n\
# Find the noVNC launcher dynamically\n\
NOVNC_PATH=$(find /usr -name vnc_lite.html -o -name launch.sh | grep novnc | head -n 1)\n\
NOVNC_DIR=$(dirname $NOVNC_PATH)\n\
\n\
x11vnc -display :1 -nopw -listen localhost -xkb -forever &\n\
\n\
# Use the correct built-in websockify/novnc utility\n\
/usr/bin/python3 /usr/share/novnc/utils/websockify/websockify --web /usr/share/novnc/ 6080 localhost:5900' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
