#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------
# OS DETECTION
# -----------------------------------------------------------------------------

detect_os() {
  case "$(uname -s)" in
    Linux*)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
          ubuntu|debian|pop|linuxmint) OS="debian" ;;
          fedora)                      OS="fedora" ;;
          *)
            echo "Unsupported Linux distro: $ID"
            exit 1
            ;;
        esac
      else
        echo "Cannot detect Linux distro (missing /etc/os-release)"
        exit 1
      fi
      ;;
    Darwin*) OS="macos" ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac

  echo "==> Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# PACKAGE HELPERS
# -----------------------------------------------------------------------------

pkg_update() {
  case "$OS" in
    debian) sudo apt update ;;
    fedora) sudo dnf check-update || true ;;
    macos)  brew update ;;
  esac
}

pkg_install() {
  case "$OS" in
    debian) sudo apt install -y "$@" ;;
    fedora) sudo dnf install -y "$@" ;;
    macos)  brew install "$@" ;;
  esac
}

# Maps a generic package name to the distro-specific name.
# Returns nothing if the package should be skipped on that OS.
pkg_name() {
  local pkg="$1"
  case "$OS" in
    debian)
      case "$pkg" in
        fd)    echo "fd-find" ;;
        bat)   echo "bat" ;;
        build) echo "build-essential" ;;
        *)     echo "$pkg" ;;
      esac
      ;;
    fedora)
      case "$pkg" in
        fd)    echo "fd-find" ;;
        bat)   echo "bat" ;;
        build) echo "gcc" "gcc-c++" "make" ;;
        *)     echo "$pkg" ;;
      esac
      ;;
    macos)
      case "$pkg" in
        build) ;; # Xcode CLT already provides this
        *)     echo "$pkg" ;;
      esac
      ;;
  esac
}

# -----------------------------------------------------------------------------
# CORE PACKAGES
# -----------------------------------------------------------------------------

install_core() {
  echo "==> Installing core packages..."

  local generic_pkgs=(build curl unzip git zsh tmux stow fzf ripgrep fd bat jq btop)
  local resolved=()

  for pkg in "${generic_pkgs[@]}"; do
    local names
    names=$(pkg_name "$pkg")
    for n in $names; do
      [ -n "$n" ] && resolved+=("$n")
    done
  done

  pkg_install "${resolved[@]}"
}

# -----------------------------------------------------------------------------
# EZA
# -----------------------------------------------------------------------------

install_eza() {
  command -v eza &> /dev/null && return

  echo "==> Installing eza..."

  case "$OS" in
    debian)
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
      ;;
    fedora)
      sudo dnf install -y eza
      ;;
    macos)
      brew install eza
      ;;
  esac
}

# -----------------------------------------------------------------------------
# FNM
# -----------------------------------------------------------------------------

install_fnm() {
  command -v fnm &> /dev/null && return

  echo "==> Installing fnm..."

  case "$OS" in
    macos) brew install fnm ;;
    *)     curl -fsSL https://fnm.vercel.app/install | bash ;;
  esac
}

# -----------------------------------------------------------------------------
# ZOXIDE
# -----------------------------------------------------------------------------

install_zoxide() {
  command -v zoxide &> /dev/null && return

  echo "==> Installing zoxide..."

  case "$OS" in
    macos)  brew install zoxide ;;
    fedora) sudo dnf install -y zoxide ;;
    *)      curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash ;;
  esac
}

# -----------------------------------------------------------------------------
# STARSHIP
# -----------------------------------------------------------------------------

install_starship() {
  command -v starship &> /dev/null && return

  echo "==> Installing starship..."

  case "$OS" in
    macos) brew install starship ;;
    *)     curl -sS https://starship.rs/install.sh | sh -s -- -y ;;
  esac
}

# -----------------------------------------------------------------------------
# LAZYGIT
# -----------------------------------------------------------------------------

install_lazygit() {
  command -v lazygit &> /dev/null && return

  echo "==> Installing lazygit..."

  case "$OS" in
    macos)
      brew install lazygit
      ;;
    fedora)
      sudo dnf copr enable -y atim/lazygit
      sudo dnf install -y lazygit
      ;;
    debian)
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep -Po '"tag_name": "v\K[^"]*')

      curl -Lo lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

      tar xf lazygit.tar.gz lazygit
      sudo install lazygit -D -t /usr/local/bin/
      rm -f lazygit lazygit.tar.gz
      ;;
  esac
}

# -----------------------------------------------------------------------------
# NEOVIM
# -----------------------------------------------------------------------------

install_neovim() {
  command -v nvim &> /dev/null && return

  echo "==> Installing neovim..."

  case "$OS" in
    macos)
      brew install neovim
      ;;
    fedora)
      sudo dnf install -y neovim
      ;;
    debian)
      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
      sudo rm -rf /opt/nvim-linux-x86_64
      sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
      sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
      rm -f nvim-linux-x86_64.tar.gz
      ;;
  esac
}

# -----------------------------------------------------------------------------
# YAZI
# -----------------------------------------------------------------------------

install_yazi() {
  command -v yazi &> /dev/null && return

  echo "==> Installing yazi..."

  case "$OS" in
    macos)
      brew install yazi
      ;;
    fedora)
      sudo dnf install -y yazi
      ;;
    debian)
      wget -qO yazi.zip \
        https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
      unzip -q yazi.zip -d yazi-temp
      sudo mv yazi-temp/*/{ya,yazi} /usr/local/bin/
      rm -rf yazi-temp yazi.zip
      ;;
  esac
}

# -----------------------------------------------------------------------------
# ZINIT
# -----------------------------------------------------------------------------

install_zinit() {
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

  [ -d "$ZINIT_HOME" ] && return

  echo "==> Installing zinit..."
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
}

# -----------------------------------------------------------------------------
# STOW DOTFILES
# -----------------------------------------------------------------------------

stow_dotfiles() {
  echo "==> Stowing dotfiles..."

  cd "$HOME/dotfiles"

  stow zshenv
  stow zsh
  stow tmux
  stow starship
  stow git
}

# -----------------------------------------------------------------------------
# DEFAULT SHELL
# -----------------------------------------------------------------------------

set_default_shell() {
  if [ "$SHELL" != "$(which zsh)" ]; then
    echo "==> Setting zsh as default shell..."
    chsh -s "$(which zsh)"
  fi
}

# -----------------------------------------------------------------------------
# TPM
# -----------------------------------------------------------------------------

install_tpm() {
  TPM_DIR="$HOME/.config/tmux/plugins/tpm"

  [ -d "$TPM_DIR" ] && return

  echo "==> Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

detect_os
pkg_update
install_core
install_eza
install_fnm
install_zoxide
install_starship
install_lazygit
install_neovim
install_yazi
install_zinit
stow_dotfiles
set_default_shell
install_tpm

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
