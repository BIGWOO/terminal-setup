#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
THEME_DIR="$ROOT/starship/themes"
TARGET_FILE="$HOME/.config/starship.toml"
BACKUP_DIR="$HOME/.config/terminal-setup-backups/starship-themes"
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
  mkdir -p "$HOME/.config" "$BACKUP_DIR"
}

backup_current() {
  if [ -f "$TARGET_FILE" ]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    cp "$TARGET_FILE" "$BACKUP_DIR/starship.toml.$ts.bak"
    echo "已備份目前設定到: $BACKUP_DIR/starship.toml.$ts.bak"
  fi
}

list_themes() {
  echo "可用 Starship 主題："
  for file in "$THEME_DIR"/*.toml; do
    basename "$file" .toml
  done | sort
  echo
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
  echo "設定檔：$TARGET_FILE"
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
