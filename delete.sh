#!/usr/bin/env bash
# Uninstall Mini user data. Leaves the Neovim binary (and brew/apt packages).
#
# Removes:
#   - the nvim config directory
#   - vim-plug, plugged plugins, CoC data
#   - nvim cache and state
#   - the old-nvim backup from install.sh
#
# Run: ./delete.sh
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HOME_DIR=${HOME:-}
INSTALL_DIR="${HOME_DIR}/.config/nvim"
BACKUP_DIR="${HOME_DIR}/.config/old-nvim"
DATA_DIR="${XDG_DATA_HOME:-$HOME_DIR/.local/share}/nvim"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME_DIR/.cache}/nvim"
STATE_DIR="${XDG_STATE_HOME:-$HOME_DIR/.local/state}/nvim"
COC_DIR="${HOME_DIR}/.config/coc"

cd "$HOME_DIR" || exit 1

looks_like_mini() {
  local dir=$1
  [ -f "$dir/init.vim" ] && [ -f "$dir/install.sh" ]
}

if ! looks_like_mini "$INSTALL_DIR" && ! looks_like_mini "$SCRIPT_DIR"; then
  echo "No Mini install found in $INSTALL_DIR or $SCRIPT_DIR"
  exit 1
fi

echo "This removes Mini config, vim-plug, CoC, and plugins."
echo "Neovim itself (the binary) is not uninstalled."
echo

print_target() {
  local path=$1
  local why=$2
  if [ -e "$path" ]; then
    printf "  [*] %s\n      %s\n" "$path" "$why"
  else
    printf "  [ ] %s\n      %s\n" "$path" "$why"
  fi
}

print_target "$DATA_DIR" "vim-plug, site, CoC/nvim data"
print_target "$CACHE_DIR" "Neovim cache"
print_target "$STATE_DIR" "Neovim state"
print_target "$COC_DIR" "CoC extensions"
print_target "$BACKUP_DIR" "Backup from install.sh"
print_target "$INSTALL_DIR" "Mini config"

echo
printf "Delete the paths marked * ? [y/N]: "
read -r ok
if [ "${ok:-n}" != "y" ] && [ "${ok:-n}" != "Y" ]; then
  echo "Aborted."
  exit 0
fi

remove_path() {
  local path=$1
  if [ -e "$path" ]; then
    echo "Removing $path"
    rm -rf "$path"
  fi
}

remove_path "$DATA_DIR"
remove_path "$CACHE_DIR"
remove_path "$STATE_DIR"
remove_path "$COC_DIR"
remove_path "$BACKUP_DIR"
remove_path "$INSTALL_DIR"

echo "Mini user data is gone. Neovim is still installed."
