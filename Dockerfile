# ==========================================
# RENDER-OPTIMIZED UBUNTU DESKTOP
# ==========================================
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080 \
    HOME=/home/ubuntu

# 2. Fix GPG Error and Install Alist
RUN rm -f /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
EXPOSE 6080

# 4. CUSTOM MANUAL ENTRYPOINT
# This manually starts the X server and VNC to avoid Supervisor PermissionErrors
RUN echo '#!/bin/bash\n\
echo "🚀 Starting Alist..."\n\
/opt/alist/alist server &\n\
\n\
echo "🖥️ Starting Xvfb and LXDE..."\n\
# Initialize X-Server\n\
Xvfb :1 -screen 0 1920x1080x16 &\n\
export DISPLAY=:1\n\
\n\
# Start LXDE Desktop Components manually\n\
lxsession -s LXDE -e LXDE &\n\
\n\
echo "🌐 Starting Web VNC on Port 6080..."\n\
# Start VNC Server and Web Proxy\n\
x11vnc -display :1 -nopw -listen localhost -xkb -forever &\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 6080' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
