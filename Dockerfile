FROM ubuntu:24.04

# Non-interactive frontend for package manager
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system essentials, SSH, Python, etc.
RUN apt-get update && apt-get install -y --no-install-recommends     openssh-server     sudo     curl     wget     git     nano     vim     htop     tmux     screen     ffmpeg     xvfb     unzip     zip     tar     build-essential     ca-certificates     net-tools     iputils-ping     python3     python3-pip     python3-venv     python3-dev     && rm -rf /var/lib/apt/lists/*

# Install Node.js (v20 LTS) and PM2
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&     apt-get install -y nodejs &&     npm install -g pm2 &&     rm -rf /var/lib/apt/lists/*

# Install Cloudflared (Optional tunnel utility)
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb &&     dpkg -i cloudflared-linux-amd64.deb &&     rm cloudflared-linux-amd64.deb

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose SSH port
EXPOSE 22

# Start container
CMD ["/start.sh"]
