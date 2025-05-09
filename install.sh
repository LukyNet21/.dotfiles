#!/bin/bash

# List of packages to install using pacman
official_packages=(
  hyprland
  xdg-desktop-portal-hyprland
  stow
  vim
  neovim
  git
  curl
  htop
  waybar
  rofi-wayland
  swaync
  tmux
  zsh
  unzip
  fzf
  hyprpolkitagent
  hypridle
  hyprlock
  bluez
  bluez-utils
  blueman
  wireplumber
  lazygit
  pavucontrol
  brightnessctl
  nwg-look
  flatpak
)

# List of AUR packages to install
aur_packages=(
  wlogout
  oh-my-posh
)

# List of Flatpak apps to install
flatpak_apps=(
  org.kde.ark
  org.gnome.clocks
  org.gnome.Calculator
  org.gnome.Characters
  org.kde.kwrite
  org.videolan.VLC
)

# Function to install yay if it's not already installed
install_yay() {
  if ! command -v yay &>/dev/null; then
    echo "yay not found, installing..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)

    rm -rf /tmp/yay
  else
    echo "yay is already installed."
  fi
}

echo "Updating package database..."
sudo pacman -Sy

echo "Installing official packages: ${official_packages[*]}"
for pkg in "${official_packages[@]}"; do
  if pacman -Qi "$pkg" &>/dev/null; then
    echo "$pkg is already installed."
  else
    sudo pacman -S --noconfirm "$pkg"
  fi
done

install_yay

echo "Installing AUR packages: ${aur_packages[*]}"
for pkg in "${aur_packages[@]}"; do
  if yay -Qi "$pkg" &>/dev/null; then
    echo "$pkg is already installed (AUR)."
  else
    yay -S --noconfirm "$pkg"
  fi
done

echo "Installing Flatpak apps: ${flatpak_apps[*]}"
for app in "${flatpak_apps[@]}"; do
  if flatpak info "$app" &>/dev/null; then
    echo "$app is already installed (Flatpak)."
  else
    flatpak install --assumeyes "$app"
  fi
done

echo "All done!"
