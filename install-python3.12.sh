#!/bin/bash
set -e

echo "🧼 Removing command-not-found and cleaning to avoid apt_pkg errors..."
sudo apt remove --purge -y command-not-found || true
sudo rm -f /usr/lib/cnf-update-db || true

echo "🔄 Updating package lists..."
sudo apt update

echo "📦 Installing dependencies..."
sudo apt install -y software-properties-common curl

echo "➕ Adding deadsnakes PPA..."
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

echo "🐍 Installing Python 3.12..."
sudo apt install -y python3.12 python3.12-venv python3.12-dev

echo "⚙️ Setting python3 to point to python3.12..."
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
sudo update-alternatives --set python3 /usr/bin/python3.12

echo "📥 Installing/upgrading pip..."
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3
python3 -m pip install --upgrade pip

echo "✅ Installation complete"
python3 --version
pip3 --version
