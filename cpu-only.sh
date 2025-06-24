#!/bin/bash

set -e

echo_green() {
    GREEN_TEXT="\033[32m"
    RESET_TEXT="\033[0m"
    echo -e "${GREEN_TEXT}$1${RESET_TEXT}"
}

install_if_missing() {
    for pkg in "$@"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo_green ">> Installing $pkg..."
            sudo apt install -y "$pkg"
        else
            echo ">> $pkg already installed. Skipping."
        fi
    done
}

echo_green ">> Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

echo_green ">> Installing general tools if missing..."
install_if_missing screen curl iptables build-essential git wget lz4 jq make gcc nano \
    automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev \
    tar clang bsdmainutils ncdu unzip python3 python3-pip python3-venv python3-dev

echo_green ">> Checking Node.js..."
if ! command -v node >/dev/null 2>&1; then
    echo_green ">> Installing latest Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo ">> Node.js already installed: $(node -v)"
fi

echo_green ">> Checking Yarn..."
if ! command -v yarn >/dev/null 2>&1; then
    echo_green ">> Installing Yarn via npm..."
    sudo npm install -g yarn
else
    echo ">> Yarn is already installed: $(yarn -v)"
fi

# Optional fallback Yarn install
if [ ! -d "$HOME/.yarn" ]; then
    echo_green ">> Installing Yarn (fallback)..."
    curl -o- -L https://yarnpkg.com/install.sh | bash
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
    echo 'export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

# === Python Virtual Environment Setup ===
echo_green ">> Setting up Python virtual environment..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate

# === Environment Variables ===
export CPU_ONLY=1
export CUDA_VISIBLE_DEVICES=""
export HF_HUB_DOWNLOAD_TIMEOUT=300
export WANDB_MODE=disabled

# === Run swarm launcher ===
echo_green ">> Launching RL Swarm"
chmod +x run_rl_swarm.sh
./run_rl_swarm.sh
