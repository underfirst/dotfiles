#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_DIR="$HOME/.config"

link_if_missing() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return 0
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Keep existing path: $target"
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
}

clone_if_missing() {
  local repository="$1"
  local target="$2"

  if [ -e "$target" ]; then
    echo "Keep existing repository path: $target"
    return 0
  fi
  git clone "$repository" "$target"
}

echo "Install yazi assets and tmux plugins."
mkdir -p "$HOME/.config/yazi" "$HOME/.tmux/plugins"

echo "Link mise global configuration when it does not exist."
mkdir -p "$HOME/.config/mise"
for mise_file in config.toml config.macos.toml config.linux.toml; do
  link_if_missing "$ROOT_DIR/mise/$mise_file" "$HOME/.config/mise/$mise_file"
done
for mise_fragment in "$ROOT_DIR"/mise/conf.d/*.toml; do
  link_if_missing "$mise_fragment" "$HOME/.config/mise/conf.d/$(basename "$mise_fragment")"
done

clone_if_missing https://github.com/yazi-rs/flavors.git "$HOME/.config/yazi/flavors"
link_if_missing "$ROOT_DIR/configs/yazi/init.lua" "$HOME/.config/yazi/init.lua"
link_if_missing "$ROOT_DIR/configs/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
link_if_missing "$ROOT_DIR/configs/yazi/package.toml" "$HOME/.config/yazi/package.toml"
link_if_missing "$ROOT_DIR/configs/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
link_if_missing "$ROOT_DIR/configs/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
ya pkg install

if [ ! -d "$HOME/.tmux/plugins/tpm/.git" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

echo "Apply dotfiles."
link_if_missing "$ROOT_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_if_missing "$ROOT_DIR/.vimrc" "$HOME/.vimrc"
link_if_missing "$ROOT_DIR/nvim" "$CONFIG_DIR/nvim"
link_if_missing "$ROOT_DIR/configs/wezterm/wezterm.lua" "$CONFIG_DIR/wezterm/wezterm.lua"

if [ ! -e "$CONFIG_DIR/starship.toml" ]; then
  mkdir -p "$CONFIG_DIR"
  cp "$ROOT_DIR/configs/starship.toml" "$CONFIG_DIR/starship.toml"
fi

if ! grep -Fqx "source $ROOT_DIR/.zshrc" "$HOME/.zshrc" 2>/dev/null; then
  printf "\nsource %s/.zshrc\n" "$ROOT_DIR" >> "$HOME/.zshrc"
fi

echo "Apply git configuration."
git config --global merge.tool ec
git config --global pull.rebase true
git config --global rerere.enabled true
git config --global fetch.prune true
git config --global rebase.autoStash true
git config --global core.editor "nvim"

echo "Set up Neovim."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+TSUpdate" +qa
nvim --headless "+MasonInstall lua-language-server pyright clangd cmakelang cmakelint docker-compose-language-service dockerfile-language-server json-lsp markdownlint-cli2 marksman ruff shfmt tree-sitter-cli yaml-language-server" +qa
nvim --headless "+MasonUpdate" +qa

echo "Initialize zsh plugins."
zsh -ic "exit"
