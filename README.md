# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone https://github.com/<username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

The install script auto-detects your OS and uses the appropriate package manager:

| OS               | Package Manager |
|------------------|-----------------|
| Debian / Ubuntu  | `apt`           |
| Fedora           | `dnf`           |
| macOS            | `brew`          |

## What's Included

| Package    | Description                                                                 |
|------------|-----------------------------------------------------------------------------|
| `zshenv`   | Sets `ZDOTDIR` so Zsh loads its config from `~/.config/zsh`                 |
| `zsh`      | Zsh configuration with Zinit plugin manager, aliases, and completions       |
| `starship` | [Starship](https://starship.rs) prompt with Kanagawa pastel theme           |
| `tmux`     | Tmux configuration with Kanagawa theme, vim-tmux-navigator, CPU/battery bar |
| `git`      | Git configuration with user info and sensible defaults                      |

## Package Contents

### zshenv
- `.zshenv` — Exports `ZDOTDIR="$HOME/.config/zsh"` so Zsh finds its config in the XDG location

### zsh
- `.config/zsh/.zshrc` — Full Zsh setup including:
  - **Plugin manager:** [Zinit](https://github.com/zdharma-continuum/zinit)
  - **Plugins:** zsh-completions, zsh-autosuggestions, fast-syntax-highlighting, fzf-tab
  - **Tools:** Starship prompt, Zoxide (smart cd), fnm (Node.js version manager)
  - **Aliases:** `vim`→`nvim`, `ls`→`eza`, `cat`→`batcat`, `lg`→`lazygit`
  - **History:** 10,000 entries, shared across sessions, ignores duplicates

### starship
- `.config/starship.toml` — Custom prompt with Kanagawa color palette, icons for languages (Node.js, Rust, Go, Docker), git status, and time

### tmux
- `.config/tmux/tmux.conf` — Mouse support, 256 colors, vi mode, pane resizing with H/J/K/L
- `.config/tmux/themes/kanagawa/` — Kanagawa Wave color scheme with rounded window tabs
- **Plugins:** tpm, tmux-sensible, vim-tmux-navigator, tmux-cpu, tmux-battery

### git
- `.gitconfig` — User name/email, default branch (`main`), pull behavior

## Install Script

The `scripts/install.sh` script detects your OS and will:

1. **Install core packages** using the native package manager:
   - `curl`, `unzip`, `git`, `zsh`, `tmux`, `stow`, `fzf`, `ripgrep`, `fd`, `bat`, `jq`, `btop`
   - Build tools (`build-essential` / `gcc` / Xcode CLT)
2. **Install additional tools:**
   - [eza](https://github.com/eza-community/eza) — Modern `ls` replacement
   - [fnm](https://github.com/Schniz/fnm) — Fast Node.js version manager
   - [zoxide](https://github.com/ajeetdsouza/zoxide) — Smarter `cd` command
   - [starship](https://starship.rs) — Cross-shell prompt
   - [lazygit](https://github.com/jesseduffield/lazygit) — Terminal UI for git
   - [neovim](https://neovim.io) — Hyperextensible Vim-based editor
   - [yazi](https://github.com/sxyazi/yazi) — Terminal file manager
   - [zinit](https://github.com/zdharma-continuum/zinit) — Zsh plugin manager
3. **Stow all dotfiles** (zshenv, zsh, tmux, starship, git)
4. **Set Zsh** as default shell
5. **Install [TPM](https://github.com/tmux-plugins/tpm)** (Tmux Plugin Manager)

## Manual Installation with Stow

If you prefer to set things up yourself:

### Using Stow

GNU Stow creates symlinks from your home directory to the dotfiles repo.

```bash
cd ~/dotfiles

# Stow individual packages
stow zshenv    # Creates ~/.zshenv
stow git       # Creates ~/.gitconfig
stow starship  # Creates ~/.config/starship.toml
stow tmux      # Creates ~/.config/tmux/
stow zsh       # Creates ~/.config/zsh/

# Or stow everything at once
stow */
```

### How Stow Works

Each folder in this repo is a "package". Stow symlinks the contents relative to the parent directory (default: `$HOME`).

```
dotfiles/
├── zshenv/
│   └── .zshenv             → ~/.zshenv
├── zsh/
│   └── .config/
│       └── zsh/
│           └── .zshrc      → ~/.config/zsh/.zshrc
├── starship/
│   └── .config/
│       └── starship.toml   → ~/.config/starship.toml
├── tmux/
│   └── .config/
│       └── tmux/
│           └── tmux.conf   → ~/.config/tmux/tmux.conf
└── git/
    └── .gitconfig          → ~/.gitconfig
```

### XDG Base Directory

This setup follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html). Configs live in `~/.config/` instead of cluttering your home directory.

The `zshenv` package places a `.zshenv` in `$HOME` that sets `ZDOTDIR="$HOME/.config/zsh"`, which tells Zsh to load `.zshrc` from there.

### Unstow (Remove Symlinks)

```bash
cd ~/dotfiles
stow -D zshenv   # Remove zshenv symlink
stow -D git      # Remove git symlinks
stow -D tmux     # Remove tmux symlinks
```

## Post-Installation

### Tmux Plugins

After starting tmux, install plugins with:

```
prefix + I
```

(Default prefix is `Ctrl+b`)

### Zsh

Restart your terminal or run:

```bash
exec zsh
```

Zinit will automatically install plugins on first launch.

## License

MIT
