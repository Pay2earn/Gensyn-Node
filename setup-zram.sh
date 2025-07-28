#!/bin/bash
set -e

echo "📦 Installing zram-tools..."
sudo apt update
sudo apt install -y zram-tools

echo "⚙️ Configuring zram..."
sudo tee /etc/default/zramswap > /dev/null <<EOF
ALGO=zstd
PERCENT=100
PRIORITY=32767
EOF

echo "🔄 Restarting zramswap..."
sudo systemctl restart zramswap
sudo systemctl enable zramswap

# ✅ Create 40GB swapfile if it doesn't exist
if [ ! -f /swapfile ]; then
    echo "➕ Creating 40GB swapfile..."
    sudo fallocate -l 40G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1G count=40
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
fi

# ✅ Add swapfile to /etc/fstab if not already present
if ! grep -q '^/swapfile' /etc/fstab; then
    echo "📌 Adding swapfile to /etc/fstab..."
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# ✅ Enable swapfile
sudo swapon /swapfile || echo "⚠️ Failed to swapon /swapfile"

# 🧠 Set swappiness
grep -q 'vm.swappiness' /etc/sysctl.conf || echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.swappiness=10

# 📊 Show current memory and swap usage
echo ""
echo "✅ zram + 40GB swapfile setup complete."
echo "Current swap devices:"
swapon --show
echo ""
echo "Memory overview:"
free -h
