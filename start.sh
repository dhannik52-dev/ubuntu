#!/bin/bash
set -e

# ====================================================
# CONFIGURATION & ENVIRONMENT VARIABLES
# ====================================================
SSH_USER="${SSH_USER:-ipx}"
SSH_PASSWORD="${SSH_PASSWORD:-${PASSWORD:-D1H2A3N4@1}}"
ROOT_PASSWORD="${ROOT_PASSWORD:-${SSH_PASSWORD}}"

# ====================================================
# 1. SETUP ROOT PASSWORD
# ====================================================
echo "root:$ROOT_PASSWORD" | chpasswd

# ====================================================
# 2. CREATE USER & SUDO PRIVILEGES
# ====================================================
echo "Configuring user: $SSH_USER..."
if ! id "$SSH_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$SSH_USER"
fi

echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo "$SSH_USER"

# Sudo without password
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$SSH_USER"
chmod 440 "/etc/sudoers.d/$SSH_USER"

# ====================================================
# 3. CONFIGURE OPENSSH SERVER
# ====================================================
mkdir -p /run/sshd
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/railway.conf <<EOF
Port 22
ListenAddress 0.0.0.0
PasswordAuthentication yes
KbdInteractiveAuthentication no
PermitRootLogin yes
UsePAM no
X11Forwarding yes
PrintMotd no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

# Generate host keys
ssh-keygen -A

# Test SSH configuration
/usr/sbin/sshd -t

echo ""
echo "======================================"
echo " 🚀 RAILWAY UBUNTU VPS READY"
echo " 👤 User: $SSH_USER (or root)"
echo " 🔑 Password: $SSH_PASSWORD"
echo " 🌐 Internal Port: 22"
echo "======================================"
echo ""

# Keep container running 24/7 with SSH Daemon
exec /usr/sbin/sshd -D -e
 
