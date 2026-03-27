#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -d "$SCRIPT_DIR/../starship/themes" ]; then
  THEME_DIR="$(cd "$SCRIPT_DIR/../starship/themes" && pwd)"
else
  THEME_DIR="$HOME/.config/terminal-setup/starship/themes"
fi
TARGET_FILE="$HOME/.config/starship.toml"
BACKUP_DIR="$HOME/.config/terminal-setup-backups/starship-themes"
INSTALL_THEME_DIR="$HOME/.config/terminal-setup/starship/themes"
DEFAULT_THEME="tokyo-dusk"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") list
  $(basename "$0") apply <theme>
  $(basename "$0") apply --default

Available themes:
  tokyo-dusk
  nordic-monolith
  deep-sea-trench
  vintage-terminal
EOF
}

ensure_dirs() {
  mkdir -p "$HOME/.config" "$BACKUP_DIR" "$INSTALL_THEME_DIR"
}

backup_current() {
  if [ -f "$TARGET_FILE" ]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    cp "$TARGET_FILE" "$BACKUP_DIR/starship.toml.$ts.bak"
  fi
}

detect_current_theme() {
  if [ ! -f "$TARGET_FILE" ]; then
    return 1
  fi

  local theme
  for file in "$THEME_DIR"/*.toml; do
    [ -e "$file" ] || continue
    theme="$(basename "$file" .toml)"
    if cmp -s "$file" "$TARGET_FILE"; then
      printf '%s\n' "$theme"
      return 0
    fi
  done

  return 1
}

list_themes() {
  local current_theme=""
  if current_theme="$(detect_current_theme 2>/dev/null)"; then
    :
  else
    current_theme=""
  fi

  echo "可用 Starship 主題："
  for file in "$THEME_DIR"/*.toml; do
    [ -e "$file" ] || continue
    local theme
    theme="$(basename "$file" .toml)"
    if [ "$theme" = "$current_theme" ]; then
      echo "* $theme"
    else
      echo "  $theme"
    fi
  done | sort
  echo
  if [ -n "$current_theme" ]; then
    echo "目前主題：$current_theme"
  else
    echo "目前主題：自訂或未安裝"
  fi
  echo "預設主題：$DEFAULT_THEME"
}

apply_theme() {
  local theme="$1"
  local source_file="$THEME_DIR/$theme.toml"

  if [ ! -f "$source_file" ]; then
    echo "找不到主題：$theme" >&2
    echo >&2
    list_themes >&2
    exit 1
  fi

  ensure_dirs
  backup_current
  cp "$source_file" "$TARGET_FILE"

  echo "已套用 Starship 主題：$theme"
  echo "請執行：exec zsh"
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    list)
      list_themes
      ;;
    apply)
      local theme="${2:-}"
      if [ -z "$theme" ]; then
        usage
        exit 1
      fi
      if [ "$theme" = "--default" ]; then
        theme="$DEFAULT_THEME"
      fi
      apply_theme "$theme"
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      echo "未知指令：$cmd" >&2
      echo >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
