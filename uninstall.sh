#!/usr/bin/env bash
# uninstall.sh - Remove tm (tmux session manager)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  Uninstalling tm..."
echo ""

# Remove tm symlink
if [[ -L "$HOME/.local/bin/tm" ]]; then
    rm "$HOME/.local/bin/tm"
    echo "  Removed ~/.local/bin/tm"
fi

# Remove tmux.conf symlink
if [[ -L "$HOME/.tmux.conf" ]]; then
    rm "$HOME/.tmux.conf"
    echo "  Removed ~/.tmux.conf"

    # Restore backup if one exists
    latest_backup="$(ls -t "$HOME/.tmux.conf.backup."* 2>/dev/null | head -1 || true)"
    if [[ -n "$latest_backup" ]]; then
        cp "$latest_backup" "$HOME/.tmux.conf"
        echo "  Restored $latest_backup"
    fi
fi

# Remove the session-picker hook from ~/.bashrc
BASHRC="$HOME/.bashrc"
MARKER_BEGIN="# >>> tmux_setting session picker >>>"
MARKER_END="# <<< tmux_setting session picker <<<"
if [[ -f "$BASHRC" ]] && grep -qF "$MARKER_BEGIN" "$BASHRC"; then
    tmp="$(mktemp)"
    sed "/$MARKER_BEGIN/,/$MARKER_END/d" "$BASHRC" > "$tmp" && mv "$tmp" "$BASHRC"
    echo "  Removed session-picker hook from ~/.bashrc"
fi

echo ""
echo "  Done. tm has been removed."
echo ""
