# ==========================================
# FINAL STABLE UBUNTU DESKTOP FOR RENDER
# Includes: Persistence, Alist, and Web VNC
# ==========================================
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080

# 2. Install Alist (Automatic Installation)
RUN apt-get update && apt-get install -y curl ca-certificates && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
# This image serves the desktop on port 80 by default; 
# we keep 6080 for your consistency.
EXPOSE 6080

# 4. FINAL STABLE ENTRYPOINT
# This ensures AList starts AND the built-in desktop supervisor runs correctly
RUN echo '#!/bin/bash\n\
echo "🚀 Initializing Render VM Environment..."\n\
/opt/alist/alist server &\n\
echo "✅ Alist started in background"\n\
\n\
echo "🖥️ Starting Desktop Environment..."\n\
# The original entrypoint for this image is /startup.sh\n\
/startup.sh' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
# Note: On Render, mount your Disk to /home/ubuntu
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
