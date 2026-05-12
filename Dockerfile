# ==========================================
# STABLE UBUNTU DESKTOP FOR RENDER (GPG FIX)
# ==========================================
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# 1. Environment Configuration
ENV VNC_PASSWORD=ubuntu \
    USER=ubuntu \
    PASSWORD=ubuntu \
    PORT=6080

# 2. Fix GPG Error and Install Alist
# We remove the broken chrome list so apt-get update doesn't fail
RUN rm -f /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install /opt/alist

# 3. Port Mapping
EXPOSE 6080

# 4. ENTRYPOINT
RUN echo '#!/bin/bash\n\
echo "🚀 Initializing Render VM Environment..."\n\
/opt/alist/alist server &\n\
echo "✅ Alist started in background"\n\
\n\
echo "🖥️ Starting Desktop Environment..."\n\
/startup.sh' > /render-entrypoint.sh && \
chmod +x /render-entrypoint.sh

# 5. Persistence
VOLUME ["/home/ubuntu"]

ENTRYPOINT ["/render-entrypoint.sh"]
