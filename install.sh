#!/usr/bin/env bash
# Install Mini the same way Current does, in shell:
# Homebrew, pacman, apt, dnf. Never delete the directory we are running from.
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HOME_DIR=${HOME:-}
INSTALL_DIR="${HOME_DIR}/.config/nvim"
BACKUP_DIR="${HOME_DIR}/.config/old-nvim"

cd "$HOME_DIR" || exit 1

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_manager() {
  if command_exists brew; then
    echo brew
    return
  fi
  if command_exists pacman; then
    echo pacman
    return
  fi
  if command_exists apt-get; then
    echo apt-get
    return
  fi
  if command_exists dnf; then
    echo dnf
    return
  fi
  echo ""
}

install_plug() {
  local dest="${XDG_DATA_HOME:-$HOME_DIR/.local/share}/nvim/site/autoload/plug.vim"
  mkdir -p "$(dirname "$dest")"
  curl -fLo "$dest" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_packages() {
  local manager=$1
  echo "Detected package manager: $manager"
  case "$manager" in
    brew)
      brew install neovim node pnpm
      ;;
    pacman)
      sudo pacman -Sy --noconfirm neovim nodejs pnpm
      ;;
    apt-get)
      sudo apt-get update
      sudo apt-get install -y neovim nodejs
      if ! command_exists pnpm; then
        curl -fsSL https://get.pnpm.io/install.sh | sh -
      fi
      ;;
    dnf)
      sudo dnf install -y neovim nodejs
      if ! command_exists pnpm; then
        curl -fsSL https://get.pnpm.io/install.sh | sh -
      fi
      ;;
    *)
      echo "No supported package manager (need brew, pacman, apt-get, or dnf)."
      echo "Install Neovim, Node.js, pnpm, and vim-plug by hand, then open nvim."
      return 1
      ;;
  esac
}

place_config() {
  if [ "$SCRIPT_DIR" = "$INSTALL_DIR" ]; then
    echo "Already running from $INSTALL_DIR — nothing to copy."
    return 0
  fi

  mkdir -p "$(dirname "$INSTALL_DIR")"

  if [ -e "$INSTALL_DIR" ]; then
    echo "A config already exists at $INSTALL_DIR."
    printf "Keep it as a backup at %s? [y/N]: " "$BACKUP_DIR"
    read -r keep
    if [ "${keep:-n}" = "y" ] || [ "${keep:-n}" = "Y" ]; then
      rm -rf "$BACKUP_DIR"
      mv "$INSTALL_DIR" "$BACKUP_DIR"
    else
      rm -rf "$INSTALL_DIR"
    fi
  fi

  mkdir -p "$INSTALL_DIR"
  cp -R "$SCRIPT_DIR"/. "$INSTALL_DIR"/
  echo "Copied Mini to $INSTALL_DIR"
}

printf "Use a custom config directory? (default %s) [y/N]: " "$INSTALL_DIR"
read -r custom
if [ "${custom:-n}" = "y" ] || [ "${custom:-n}" = "Y" ]; then
  printf "Enter the path: "
  read -r custom_path
  if [ -n "${custom_path:-}" ]; then
    case "$custom_path" in
      ~*) INSTALL_DIR="${HOME_DIR}${custom_path#\~}" ;;
      *) INSTALL_DIR=$custom_path ;;
    esac
  fi
fi

MANAGER=$(detect_manager)
if [ -z "$MANAGER" ]; then
  echo "Could not detect brew, pacman, apt-get, or dnf."
else
  if [ "$MANAGER" != "brew" ]; then
    echo "Administrator privileges are required to install system packages."
    sudo -v || exit 1
  fi
  install_packages "$MANAGER" || true
fi

install_plug || echo "Could not download vim-plug."
place_config

cat <<EOF

Mini is in place at:
  $INSTALL_DIR

Open a new terminal, then:

  nvim

Inside Neovim:

  :PlugInstall
  :source %
  :CocInstall

Or <Space> p i for PlugInstall.

Edit the config with:

  nvim $INSTALL_DIR/init.vim
EOF
