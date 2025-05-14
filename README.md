![image](https://github.com/user-attachments/assets/8ad5a694-e287-4d45-ba57-203f58a19714)

# Run RL Swarm (Testnet) Node
RL Swarm is a fully open-source framework developed by GensynAI for building reinforcement learning (RL) training swarms over the internet. This guide walks you through setting up an RL Swarm node and a web UI dashboard to monitor swarm activity.

## Hardware Requirements
There are currently multiple swarms running on the Testnet, each training on a different data set. The current list of available models and swarms include:
* Models: `Qwen 2.5 0.5B`, `Qwen 2.5 1.5B`, `Qwen 2.5 7B`, `Qwen 2.5 32B (4 bit)` & `Qwen 2.5 72B (4 bit)`
* Swarms: `Math (GSM8K dataset)` & `Math Hard (DAPO-Math 17K dataset)`

Your hardware requirements will vary depending on which swarm and model you choose. Users with less powerful hardware should select a smaller model (e.g. Qwen 0.5B or 1.5B) and smaller dataset (GSM8K) `A`. Users with more powerful hardware can select a larger model (e.g. Qwen 7B, 32B or 72B) and larger dataset (DAPO-Math 17K) `B`. The requirements for each are listed below:

### Small model (0.5B or 1.5B) + Math (GSM8K dataset)
* `CPU-only`: arm64 or x86 CPU with minimum 16gb ram (note that if you run other applications during training it might crash training).

OR

* `GPU`: 
  * RTX 3090
  * RTX 4090
  * A100
  * H100
  * `≥24GB vRAM` GPU is recommended, but Gensyn now supports `>24GB vRAM` GPUs too.
  * `≥12.4` CUDA Driver

### Big model (7B, 32B or 72B) + Math Hard (DAPO-Math 17K dataset)
* `GPU`: A100 (80GB) or H100 (80GB)

---

## ⚡ Quick Start

* Clone repo
```bash
git clone https://github.com/gensyn-ai/rl-swarm/
cd rl-swarm
```

* Add a script
```bash
nano cpu-only.sh
```

* Copy and paste to cpu-only.sh
```bash
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

# === Clone or Update the Repository ===
REPO_NAME="rl-swarm"
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"

if [ -d "$REPO_NAME/.git" ]; then
    echo_green ">> Repository exists. Pulling latest changes..."
    cd "$REPO_NAME"
    git pull origin main || git pull
else
    echo_green ">> Cloning RL Swarm repository..."
    git clone "$REPO_URL"
    cd "$REPO_NAME"
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

# === Run swarm launcher ===
echo_green ">> Launching RL Swarm"
chmod +x run_rl_swarm.sh
./run_rl_swarm.sh
```
To save the file: Press `Ctrl + X`, `Y` & `Enter`

* Give permission to run the script
```bash
chmod +x cpu-only.sh
```

* Open a screen to run it in background
```bash
screen -S swarm
```

* Run with sudo
```bash
sudo ./cpu-only.sh
```
* `Would you like to connect to the Testnet? [Y/n]` >>> Press `Y` to join testnet
* `Which swarm would you like to join (Math (A) or Math Hard (B))? [A/b]` >>> We have two type of Swarms:
  * `A`: Math (GSM8K dataset) -- Lower systems (>8GB) -- Use Small model (0.5B or 1.5B) for it.
  * `B`: Math Hard (DAPO-Math 17K dataset) -- Higher systems -- Use Big model (7B, 32B or 72B) for it.
* `How many parameters (in billions)? [0.5, 1.5, 7, 32, 72]` >>> `0.5` is minimal and `72` is very big model. Choose based on your system.
* Check Step [Hardware Requirement](https://github.com/0xmoei/gensyn-ai/blob/main/README.md#hardware-requirements) for more clue.

---

## 5) Login
**1- You have to receive `Waiting for userData.json to be created...` in logs**

![image](https://github.com/user-attachments/assets/140f7d32-844f-4cf0-aac4-a91e9a14c1aa)

**2- Open login page in browser**
* **Local PC:** `http://localhost:3000/`
* **GPU Cloud Users:** Before conneting to your GPU, Add this flag: `-L 3000:localhost:3000` in front of your GPU's SSH Command, to be able to open `http://localhost:3000/` in your Local PC's browser.
* **VPS users:** You have to forward port by entering a command in the `Windows Powershell` of your local PC:
  * In windows start menu, Search **Windows Powershell** and open its terminal in your local PC.
  * Enter the command below and replace your vps ip with `Server_IP` and your vps port(.eg 22) with `SSH_PORT`
  ```
  ssh -L 3000:localhost:3000 root@Server_IP -p SSH_PORT
  ```
  * ⚠️ Make sure you enter the command in your own local PC's Windows Powershell and NOT your VPS terminal.
  * This prompts you to enter your VPS password, when you enter it, you connect and tunnel to your vps
  * Now go to browser and open `http://localhost:3000/` and login

**3- Login with your preferred method**

![image](https://github.com/user-attachments/assets/f33ea530-b15f-4af7-a317-93acd8618a9f)

* After login, your terminal starts installation.

**4- Optional: Push models to huggingface**
* Enter your `HuggingFace` access token you've created when it prompted.
* This will need `2GB` upload bandwidth for each model you train, you can pass it by entering `N`.

![image](https://github.com/user-attachments/assets/11c3a798-49c2-4a87-9e0b-359f3378c9e2)

---

### Node Name
* Now your node started running, Find your name after word `Hello`, like mine is `whistling hulking armadillo` as in the image below (You can use `CTRL+SHIFT+F` to search Hello in terminal)

![image](https://github.com/user-attachments/assets/a1abdb1a-aa11-407f-8e5b-abe7d0a6b0f3)

---

### Screen commands
* Minimize: `CTRL` + `A` + `D`
* Return: `screen -r swarm`
* Stop and Kill: `screen -XS swarm quit`

---

## Backup
**You need to backup `swarm.pem`**.
### `VPS`:
Connect your VPS using `Mobaxterm` client to be able to move files to your local system. Back up these files:**
* `/root/rl-swarm/swarm.pem`

### `WSL`:
Search `\\wsl.localhost` in your ***Windows Explorer*** to see your Ubuntu directory. Your main directories are as follows:
* If installed via a username: `\\wsl.localhost\Ubuntu\home\<your_username>`
* If installed via root: `\\wsl.localhost\Ubuntu\root`
* Look for `rl-swarm/swarm.pem`

### `GPU servers (.eg, Hyperbolic)`:
**1- Connect to your GPU server by entering this command in `Windows PowerShell` terminal**
```
sftp -P PORT ubuntu@xxxx.hyperbolic.xyz
```
* Replace `ubuntu@xxxx.hyperbolic.xyz` with your given GPU hostname
* Replace `PORT` with your server port (in your server ssh connection command)
* `ubuntu` is the user of my hyperbolic gpu, it can be ***anything else*** or it's `root` if you test it out for `vps`

Once connected, you’ll see the SFTP prompt:
```
sftp>
```

**2- Navigate to the Directory Containing the Files**
 * After connecting, you’ll start in your home directory on the server. Use the `cd` command to move to the directory of your files:
 ```
 cd /home/ubuntu/rl-swarm
 ```

**3- Download Files**
 * Use the `get` command to download the files to your `local system`. They’ll save to your current local directory unless you specify otherwise:
 ```
 get swarm.pem
 ```
* Downloaded file is in the main directory of your `Powershell` or `WSL` where you entered the sFTP command.
  * If entered sftp command in `Porwershell`, the `swarm.pem` file might be in `C:\Users\<pc-username>`.
* You can now type `exit` to close connection. The files are in the main directory of your `Powershell` or `WSL` where you entered the first SFTP command.

---

### Recovering Backup file (upload)
If you need to upload files from your `local machine` to the `server`.
* `WSL` & `VPS`: Drag & Drop option.

**`GPU servers (.eg, Hyperbolic)`:**

1- Connect to your GPU server using sFTP

2- Upload Files Using the `put` Command:

In SFTP, the put command uploads files from your local machine to the server. 
```bash
put swarm.pem /home/ubuntu/rl-swarm/swarm.pem
```

---

# Node Health
### Official Dashboards
* Math (GSM8K dataset): https://dashboard-math.gensyn.ai/
* Math Hard (DAPO-Math 17K dataset): https://dashboard-math-hard.gensyn.ai/

![image](https://github.com/user-attachments/assets/cd8e8cd3-f057-450a-b1a2-a90ca10aa3a6)

### Telegram Bot
Search you `Node ID` here with `/check` here: https://t.me/gensyntrackbot 
* `Node-ID` is near your Node name

![image](https://github.com/user-attachments/assets/2946ddf4-f6ef-4201-b6a0-cb5f16fb4cec)

* ⚠️ If receiving `EVM Wallet: 0x0000000000000000000000000000000000000000`, your `onchain-participation` is not being tracked and you have to Install with `New Email` and ***Delete old `swarm.pem`***

![image](https://github.com/user-attachments/assets/8852d3b3-cb13-473e-863f-f4cbe3d0abdd)

---

# Update Node
### 1- Stop Node
```console
# list screens
screen -ls

# kill swarm screens (replace screen-id)
screen -XS screen-id quit

# You can kill by name
screen -XS swarm quit
```

### 2- Update Node Repository
**Method 1** (test this first): If you cloned official repo with no local changes:
```bash
cd rl-swarm
git pull
```

**Method 2**: If you cloned official repo with local Changes:
```console
cl rl-swarm

# Reset local changes:
git reset --hard
# Pull updates:
git pull

# Alternatively:
git fetch
git reset --hard origin/main
```
* You have to do your local changes again.

**Method 3**: Cloned unofficial repo or Try from scratch (**Recommended**):
```console
cd rl-swarm

# backup .pem
cp ./swarm.pem ~/swarm.pem

cd ..

# delete rl-swarm dir
rm -rf rl-swarm

# clone new repo
git clone https://github.com/gensyn-ai/rl-swarm

cd rl-swarm

# Recover .pem
cp ~/swarm.pem ./swarm.pem
```
* If you had any local changes, you have to do it again.

### 3- Re-run Node
Head back to [4) Run the swarm](https://github.com/0xmoei/gensyn-ai/edit/main/README.md#4-run-the-swarm) and re-run Node.

---

# Troubleshooting:

### ⚠️ Error: PS1 unbound variable
```
sed -i '1i # ~/.bashrc: executed by bash(1) for non-login shells.\n\n# If not running interactively, don'\''t do anything\ncase $- in\n    *i*) ;;\n    *) return;;\nesac\n' ~/.bashrc
```

### ⚠️ Daemon failed to start in 15.0 seconds
* Enter `rl-swarm` directory:
```bash
cd rl-swarm
```
* Activate python venv:
```bash
python3 -m venv .venv
source .venv/bin/activate
```
* Open Daemon config file:
```
nano $(python3 -c "import hivemind.p2p.p2p_daemon as m; print(m.__file__)")
```
* Search for line: `startup_timeout: float = 15`, then change `15` to `120` to increate the Daemon's timeout. the line should look like this: `startup_timeout: float = 120`
* To save the file: Press `Ctrl + X`, `Y` & `Enter`
