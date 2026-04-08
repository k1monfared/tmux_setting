#!/usr/bin/env bash
# install.sh - Install tm (tmux session manager)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo ""
echo "  Installing tm (tmux session manager)..."
echo ""

# Check dependencies
for cmd in tmux fzf; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "  Error: $cmd is required but not found."
        echo "  Install it with: sudo apt install $cmd"
        exit 1
    fi
done

# Make scripts executable
chmod +x "$SCRIPT_DIR/bin/tm"
chmod +x "$SCRIPT_DIR/bin/tm-picker"
chmod +x "$SCRIPT_DIR/bin/tm-cheatsheet"

# Symlink tmux.conf
if [[ -f "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
    echo "  Backing up existing ~/.tmux.conf to ~/.tmux.conf.backup.$TIMESTAMP"
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$TIMESTAMP"
fi
ln -sf "$SCRIPT_DIR/conf/tmux.conf" "$HOME/.tmux.conf"
echo "  Linked ~/.tmux.conf"

# Symlink tm to ~/.local/bin
mkdir -p "$HOME/.local/bin"
ln -sf "$SCRIPT_DIR/bin/tm" "$HOME/.local/bin/tm"
echo "  Linked ~/.local/bin/tm"

# Reload tmux config if tmux is running
if tmux list-sessions &>/dev/null; then
    tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "  Reloaded tmux config" || true
fi

echo ""
echo "  Done. Run 'tm' to see the cheatsheet."
echo ""

# Show cheatsheet
"$SCRIPT_DIR/bin/tm-cheatsheet"
