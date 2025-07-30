#!/bin/bash

set -e  # หยุดสคริปต์ถ้ามีคำสั่งใดล้มเหลว

echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing dependencies..."
sudo apt install -y software-properties-common

echo "➕ Adding deadsnakes PPA..."
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

echo "🐍 Installing Python 3.12..."
sudo apt install -y python3.12 python3.12-venv python3.12-dev

echo "⚙️ Setting Python 3.12 as default python3..."
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

echo "✅ Forcing python3 to use python3.12..."
sudo update-alternatives --set python3 /usr/bin/python3.12

echo "📥 Installing pip for Python 3.12..."
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3

echo "✅ Done!"
python3 --version
pip3 --version
