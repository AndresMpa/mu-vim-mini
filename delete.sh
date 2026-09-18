#!/usr/bin/env bash
# Uninstall Mini user data. Leaves the Neovim binary (and brew/apt packages).
#
# Removes:
#   - the nvim config directory
#   - this clone, if you ran ./delete.sh from mu-vim-mini
#   - vim-plug, plugged plugins, CoC data
#   - nvim cache and state
#   - the old-nvim backup from install.sh
#   - shared palettes and the last theme (~/.config/muvim)
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
THEMES_DIR="${HOME_DIR}/.config/muvim"

cd "$HOME_DIR" || exit 1

looks_like_mini() {
  local dir=$1
  [ -f "$dir/init.vim" ] && { [ -f "$dir/install.sh" ] || [ -f "$dir/delete.sh" ]; }
}

if ! looks_like_mini "$INSTALL_DIR" && ! looks_like_mini "$SCRIPT_DIR"; then
  echo "No Mini install found in $INSTALL_DIR or $SCRIPT_DIR"
  exit 1
fi

PATHS=()
WHYS=()

add_target() {
  PATHS+=("$1")
  WHYS+=("$2")
}

add_target "$DATA_DIR" "vim-plug, site, CoC/nvim data"
add_target "$CACHE_DIR" "Neovim cache"
add_target "$STATE_DIR" "Neovim state"
add_target "$COC_DIR" "CoC extensions"
add_target "$BACKUP_DIR" "Backup from install.sh"
add_target "$THEMES_DIR" "Shared palettes and last theme (~/.config/muvim)"
add_target "$INSTALL_DIR" "Mini config (~/.config/nvim)"

# Current's delete.lua removes the tree you ran it from. If Mini still
# lives in the clone (install never copied it), delete that too.
if looks_like_mini "$SCRIPT_DIR" \
  && [ "$SCRIPT_DIR" != "$INSTALL_DIR" ] \
  && [ "$SCRIPT_DIR" != "$HOME_DIR" ]; then
  add_target "$SCRIPT_DIR" "This Mini clone"
fi

echo "This removes Mini config, vim-plug, CoC, plugins, themes, and this clone if needed."
echo "Neovim itself (the binary) is not uninstalled."
echo

i=0
while [ "$i" -lt "${#PATHS[@]}" ]; do
  path=${PATHS[$i]}
  why=${WHYS[$i]}
  if [ -e "$path" ]; then
    printf "  [*] %s\n      %s\n" "$path" "$why"
  else
    printf "  [ ] %s\n      %s\n" "$path" "$why"
  fi
  i=$((i + 1))
done

echo
printf "Delete the paths marked * ? [y/N]: "
read -r ok
if [ "${ok:-n}" != "y" ] && [ "${ok:-n}" != "Y" ]; then
  echo "Aborted."
  exit 0
fi

i=0
while [ "$i" -lt "${#PATHS[@]}" ]; do
  path=${PATHS[$i]}
  if [ -e "$path" ]; then
    echo "Removing $path"
    rm -rf "$path"
  fi
  i=$((i + 1))
done

echo "Mini user data is gone. Neovim is still installed."
