# ==========================================
# FULLY AUTOMATED UBUNTU DESKTOP FOR RENDER
# Includes: Persistence, Alist, and Web VNC
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

# 3. Port Mapping for Render (Web VNC)
EXPOSE 6080

# 4. Entrypoint Script Generation
# This script starts AList and the Desktop Environment together
RUN echo '#!/bin/bash\n\
echo "🚀 Initializing Render VM Environment..."\n\
/opt/alist/alist server &\n\
echo "✅ Alist started in background"\n\
/startup.sh' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence Setup
# IMPORTANT: You must attach a "Disk" in Render Dashboard to this path
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
