#!/usr/bin/env bash

set -e

echo "==> Updating packages..."
sudo apt update

echo "==> Installing core packages..."
sudo apt install -y \
  build-essential \
  curl \
  unzip \
  git \
  zsh \
  tmux \
  stow \
  fzf \
  ripgrep \
  fd-find \
  bat \
  jq \
  btop

# -----------------------------------------------------------------------------
# EZA
# -----------------------------------------------------------------------------

if ! command -v eza &> /dev/null; then
  echo "==> Installing eza..."

  sudo mkdir -p /etc/apt/keyrings

  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg

  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] \
  http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list

  sudo chmod 644 /etc/apt/keyrings/gierens.gpg \
    /etc/apt/sources.list.d/gierens.list

  sudo apt update
  sudo apt install -y eza
fi

# -----------------------------------------------------------------------------
# FNM
# -----------------------------------------------------------------------------

if ! command -v fnm &> /dev/null; then
  echo "==> Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash
fi

# -----------------------------------------------------------------------------
# ZOXIDE
# -----------------------------------------------------------------------------

if ! command -v zoxide &> /dev/null; then
  echo "==> Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# -----------------------------------------------------------------------------
# STARSHIP
# -----------------------------------------------------------------------------

if ! command -v starship &> /dev/null; then
  echo "==> Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# -----------------------------------------------------------------------------
# LAZYGIT
# -----------------------------------------------------------------------------

if ! command -v lazygit &> /dev/null; then
  echo "==> Installing lazygit..."

  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')

  curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

  tar xf lazygit.tar.gz lazygit

  sudo install lazygit -D -t /usr/local/bin/

  rm -f lazygit lazygit.tar.gz
fi

# -----------------------------------------------------------------------------
# NEOVIM
# -----------------------------------------------------------------------------

if ! command -v nvim &> /dev/null; then
  echo "==> Installing neovim..."

  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

  rm -f nvim-linux-x86_64.tar.gz
fi

# -----------------------------------------------------------------------------
# YAZI
# -----------------------------------------------------------------------------

if ! command -v yazi &> /dev/null; then
  echo "==> Installing yazi..."

  wget -qO yazi.zip \
    https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip

  unzip -q yazi.zip -d yazi-temp

  sudo mv yazi-temp/*/{ya,yazi} /usr/local/bin/

  rm -rf yazi-temp yazi.zip
fi

# -----------------------------------------------------------------------------
# ZINIT
# -----------------------------------------------------------------------------

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  echo "==> Installing zinit..."

  mkdir -p "$(dirname "$ZINIT_HOME")"

  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# -----------------------------------------------------------------------------
# STOW DOTFILES
# -----------------------------------------------------------------------------

echo "==> Stowing dotfiles..."

cd "$HOME/dotfiles"

stow zsh
stow tmux
stow starship
stow git

# -----------------------------------------------------------------------------
# DEFAULT SHELL
# -----------------------------------------------------------------------------

echo "==> Setting zsh as default shell..."

chsh -s "$(which zsh)"

# -----------------------------------------------------------------------------
# TPM
# -----------------------------------------------------------------------------

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  echo "==> Installing tmux plugin manager..."

  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# -----------------------------------------------------------------------------
# DONE
# -----------------------------------------------------------------------------

echo ""
echo "========================================"
echo " Done."
echo " Restart your terminal or run:"
echo ""
echo "   exec zsh"
echo ""
echo " Then inside tmux press:"
echo ""
echo "   prefix + I"
echo ""
echo " to install tmux plugins."
echo "========================================"