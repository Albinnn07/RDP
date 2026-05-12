# ==========================================
# UNIVERSAL BOOT UBUNTU DESKTOP FOR RENDER
# ==========================================
FROM akarita/docker-ubuntu-desktop:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    RESOLUTION=1920x1080 \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080 \
    DEBIAN_FRONTEND=noninteractive

# 2. Install Alist (Automatic Installation)
RUN apt-get update && apt-get install -y curl ca-certificates && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
EXPOSE 6080

# 4. UNIVERSAL ENTRYPOINT
# This script finds the boot file automatically and runs it
RUN echo '#!/bin/bash\n\
echo "🚀 Initializing Render VM Environment..."\n\
/opt/alist/alist server &\n\
echo "✅ Alist started in background"\n\
\n\
echo "🔍 Locating startup script..."\n\
# Try to find common startup scripts in the image\n\
STARTUP=$(find / -name "startup.sh" -o -name "docker-startup.sh" -o -name "entrypoint.sh" | head -n 1)\n\
\n\
if [ -z "$STARTUP" ]; then\n\
  echo "❌ Could not find startup script. Attempting manual boot..."\n\
  /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf\n\
else\n\
  echo "✅ Found startup script at: $STARTUP"\n\
  exec "$STARTUP"\n\
fi' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
