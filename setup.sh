#!/bin/bash

set -e

echo "==> [1/5] Installing required packages..."
sudo apt update
sudo apt install -y \
    tesseract-ocr \
    xclip \
    maim \
    slop \
    flameshot \
    libnotify-bin \
    gsettings-desktop-schemas

echo "==> [2/5] Making sure ocr.sh exists and is executable..."
if [ ! -f ~/ocr.sh ]; then
    echo "❌ ~/ocr.sh not found. Please create your OCR script at ~/ocr.sh"
    exit 1
fi
chmod +x ~/ocr.sh

# === CONFIGURATION ===
USER_HOME="/home/$USER"
OCR_COMMAND="$USER_HOME/ocr.sh"
FLAMESHOT_COMMAND="flameshot gui"
OCR_SHORTCUT="['<Control><Alt>o']"
FLAME_SHORTCUT="['<Control><Alt>p']"
OCR_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ocr-clip/"
FLAME_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot-gui/"

echo "==> [3/5] Updating GNOME custom keyboard shortcuts..."

# Function to safely add new custom shortcut path to list
add_custom_shortcut() {
  local path=$1
  EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
  if [[ $EXISTING != *"$path"* ]]; then
    if [[ $EXISTING == "@as []" ]]; then
      NEW_LIST="['$path']"
    else
      NEW_LIST=$(echo "$EXISTING" | sed "s/]$/, '$path']/")
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"
  fi
}

# Add both shortcuts to GNOME
add_custom_shortcut "$OCR_PATH"
add_custom_shortcut "$FLAME_PATH"

echo "==> [4/5] Setting OCR shortcut..."
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$OCR_PATH name "OCR Screenshot"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$OCR_PATH command "$OCR_COMMAND"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$OCR_PATH binding "$OCR_SHORTCUT"

echo "==> [5/5] Setting Flameshot shortcut..."
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$FLAME_PATH name "Flameshot GUI"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$FLAME_PATH command "$FLAMESHOT_COMMAND"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$FLAME_PATH binding "$FLAME_SHORTCUT"

echo "✅ Setup complete!"
echo " - Press Ctrl+Alt+O to run OCR screenshot and copy text to clipboard"
echo " - Press Ctrl+Alt+P to launch Flameshot GUI for screenshots"



#!/bin/bash
set -e

echo "==> Updating apt and installing base packages..."
sudo apt update
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  software-properties-common \
  build-essential \
  git \
  htop \
  vim \
  python3 \
  python3-pip \
  python3-venv \
  python-is-python3

echo "==> Installing Node.js 18.x LTS from NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

echo "==> Installing Vite globally..."
sudo npm install -g vite

echo "==> Detecting OS for Docker installation..."
OS_ID=$(. /etc/os-release && echo "$ID")

if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
  echo "Detected OS: $OS_ID"
  echo "==> Adding Docker GPG key and repository..."

  curl -fsSL https://download.docker.com/linux/$OS_ID/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$OS_ID $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  echo "==> Installing Docker Engine..."
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io

  echo "==> Adding current user to docker group..."
  sudo usermod -aG docker $USER

  echo "==> Installing latest Docker Compose..."
  DOCKER_COMPOSE_LATEST=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url | grep linux-x86_64 | cut -d '"' -f 4)
  sudo curl -L "$DOCKER_COMPOSE_LATEST" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  echo "==> Docker and Docker Compose installed successfully!"
else
  echo "Unsupported OS for Docker installation: $OS_ID"
  echo "Please install Docker manually."
  exit 1
fi

echo "==> Installation complete!"
echo "Please log out and back in (or run 'newgrp docker') to apply docker group changes."
echo "Check docker with 'docker run hello-world'."
