#!/bin/bash

set -e

echo "🧼 Removing command-not-found to avoid apt_pkg error..."
sudo apt remove --purge -y command-not-found || true

echo "📦 Installing base dependencies..."
sudo apt install -y software-properties-common curl

echo "➕ Adding deadsnakes PPA..."
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

echo "🐍 Installing Python 3.12 and tools..."
sudo apt install -y python3.12 python3.12-venv python3.12-dev

echo "⚙️ Setting Python 3.12 as the default python3..."
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
sudo update-alternatives --set python3 /usr/bin/python3.12

echo "📥 Installing pip for Python 3.12..."
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3

echo "📌 Upgrading pip..."
python3 -m pip install --upgrade pip

echo "✅ Installation complete!"
python3 --version
pip3 --version
