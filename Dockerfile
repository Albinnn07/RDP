# ==========================================
# FIXED UBUNTU DESKTOP FOR RENDER
# ==========================================
FROM akarita/docker-ubuntu-desktop:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    RESOLUTION=1920x1080 \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080 \
    DEBIAN_FRONTEND=noninteractive

# 2. Install Alist
RUN apt-get update && apt-get install -y curl ca-certificates && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
EXPOSE 6080

# 4. FIXED Entrypoint Script
# We use 'command -v' to find the script or call the specific path
RUN echo '#!/bin/bash\n\
echo "🚀 Initializing Render VM Environment..."\n\
/opt/alist/alist server &\n\
echo "✅ Alist started in background"\n\
\n\
# Trigger the actual desktop startup script for this specific image\n\
/docker-startup.sh' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
