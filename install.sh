#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
ROOT="$(cd "$(dirname "$0")" && pwd)"
BREW_BIN="/opt/homebrew/bin/brew"

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    mkdir -p "$HOME/.config/terminal-setup-backups/$TS"
    cp "$file" "$HOME/.config/terminal-setup-backups/$TS/$(basename "$file")"
    echo "Backed up: $file"
  fi
}

ensure_homebrew() {
  if [ -x "$BREW_BIN" ]; then
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    return
  fi

  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_brew_path() {
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
}

install_packages() {
  brew install starship atuin zsh-autosuggestions
  brew install --cask ghostty font-jetbrains-mono-nerd-font || true
}

setup_dirs() {
  mkdir -p "$HOME/.config/starship" "$HOME/.config/ghostty" "$HOME/.config/zsh" "$HOME/.config/terminal-setup/starship/themes" "$HOME/.local/bin"
}

install_configs() {
  backup_file "$HOME/.config/starship.toml"
  backup_file "$HOME/.config/ghostty/config"
  backup_file "$HOME/.zshrc"

  cp "$ROOT/starship/starship.toml" "$HOME/.config/starship.toml"
  cp "$ROOT/ghostty/config" "$HOME/.config/ghostty/config"
  cp "$ROOT/zsh/zshrc.shared" "$HOME/.config/zsh/zshrc.shared"
  cp "$ROOT/starship/themes/"*.toml "$HOME/.config/terminal-setup/starship/themes/"
  cp "$ROOT/scripts/switch-starship-theme.sh" "$HOME/.local/bin/terminal-theme"
  chmod +x "$HOME/.local/bin/terminal-theme"

  if [ ! -f "$HOME/.config/zsh/zshrc.local" ]; then
    cp "$ROOT/zsh/zshrc.local.example" "$HOME/.config/zsh/zshrc.local"
  fi

  if [ ! -f "$HOME/.zshrc" ]; then
    cat > "$HOME/.zshrc" <<'EOF'
source "$HOME/.config/zsh/zshrc.shared"
[ -f "$HOME/.config/zsh/zshrc.local" ] && source "$HOME/.config/zsh/zshrc.local"
EOF
  elif ! grep -q 'zshrc.shared' "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" <<'EOF'

# terminal-setup shared config
source "$HOME/.config/zsh/zshrc.shared"
[ -f "$HOME/.config/zsh/zshrc.local" ] && source "$HOME/.config/zsh/zshrc.local"
EOF
  fi
}

verify_setup() {
  echo "\nVerifying..."
  starship --version
  atuin --version
  test -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  zsh -ic 'echo shell ok'
}

main() {
  ensure_homebrew
  ensure_brew_path
  install_packages
  setup_dirs
  install_configs
  verify_setup

  echo "\nDone. Run: exec zsh"
  echo "If Ghostty icons look wrong, set font to JetBrainsMono Nerd Font."
  echo "Switch Starship themes with: terminal-theme list / terminal-theme apply tokyo-dusk"
}

main "$@"
