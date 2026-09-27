#!/usr/bin/env bash
# install.sh - Install tm (tmux session manager)
#
# Usage: bash install.sh [--profile laptop|server|phone]
#
# The profile selects the machine-specific settings that are symlinked to
# ~/.tmux.conf.local. Defaults to "phone" on Termux, "laptop" elsewhere.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# --- Platform detection ---
IS_TERMUX=0
if [[ "${PREFIX:-}" == *com.termux* ]] || [[ -d /data/data/com.termux ]]; then
    IS_TERMUX=1
fi

# --- Profile selection ---
PROFILE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            PROFILE="${2:-}"
            shift 2
            ;;
        --profile=*)
            PROFILE="${1#*=}"
            shift
            ;;
        *)
            echo "  Unknown option: $1"
            echo "  Usage: bash install.sh [--profile laptop|server|phone]"
            exit 1
            ;;
    esac
done

if [[ -z "$PROFILE" ]]; then
    if [[ "$IS_TERMUX" -eq 1 ]]; then
        PROFILE="phone"
    else
        PROFILE="laptop"
    fi
fi

PROFILE_FILE="$SCRIPT_DIR/conf/profiles/$PROFILE.conf"
if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "  Error: unknown profile '$PROFILE'."
    echo "  Available: $(ls "$SCRIPT_DIR/conf/profiles" | sed 's/\.conf$//' | tr '\n' ' ')"
    exit 1
fi

echo ""
echo "  Installing tm (tmux session manager)..."
echo "  Platform: $([[ "$IS_TERMUX" -eq 1 ]] && echo Termux || echo Linux)  Profile: $PROFILE"
echo ""

# Check dependencies
if ! command -v tmux &>/dev/null; then
    echo "  Error: tmux is required but not found."
    if [[ "$IS_TERMUX" -eq 1 ]]; then
        echo "  Install it with: pkg install tmux"
    else
        echo "  Install it with: sudo apt install tmux"
    fi
    exit 1
fi
command -v fzf &>/dev/null || echo "  Note: fzf not found (only needed by 'tm pick')"
command -v python3 &>/dev/null || echo "  Note: python3 not found (only needed for the login picker)"

# Make scripts executable
chmod +x "$SCRIPT_DIR/bin/tm"
chmod +x "$SCRIPT_DIR/bin/tm-picker"
chmod +x "$SCRIPT_DIR/bin/tm-cheatsheet"
chmod +x "$SCRIPT_DIR/bin/tm-clip"

# Symlink tmux.conf (shared config)
if [[ -f "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
    echo "  Backing up existing ~/.tmux.conf to ~/.tmux.conf.backup.$TIMESTAMP"
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$TIMESTAMP"
fi
ln -sf "$SCRIPT_DIR/conf/tmux.conf" "$HOME/.tmux.conf"
echo "  Linked ~/.tmux.conf"

# Symlink the machine profile to ~/.tmux.conf.local
if [[ -f "$HOME/.tmux.conf.local" && ! -L "$HOME/.tmux.conf.local" ]]; then
    echo "  Backing up existing ~/.tmux.conf.local to ~/.tmux.conf.local.backup.$TIMESTAMP"
    cp "$HOME/.tmux.conf.local" "$HOME/.tmux.conf.local.backup.$TIMESTAMP"
fi
ln -sf "$PROFILE_FILE" "$HOME/.tmux.conf.local"
echo "  Linked ~/.tmux.conf.local -> conf/profiles/$PROFILE.conf"

# Symlink tm into a PATH directory. On Termux that is $PREFIX/bin, elsewhere
# ~/.local/bin (which is on PATH on typical desktop setups).
mkdir -p "$HOME/.local/bin"
if [[ "$IS_TERMUX" -eq 1 ]]; then
    ln -sf "$SCRIPT_DIR/bin/tm" "$PREFIX/bin/tm"
    echo "  Linked $PREFIX/bin/tm"
else
    ln -sf "$SCRIPT_DIR/bin/tm" "$HOME/.local/bin/tm"
    echo "  Linked ~/.local/bin/tm"
fi

# tm-clip is called by an absolute path from tmux.conf, so it always goes to
# ~/.local/bin on every platform.
ln -sf "$SCRIPT_DIR/bin/tm-clip" "$HOME/.local/bin/tm-clip"
echo "  Linked ~/.local/bin/tm-clip"

# Install the session-picker hook into ~/.bashrc (idempotent, marker-delimited).
# tm-login itself decides when to skip (inside tmux, VS Code, Guake, no picker).
BASHRC="$HOME/.bashrc"
MARKER_BEGIN="# >>> tmux_setting session picker >>>"
MARKER_END="# <<< tmux_setting session picker <<<"
if [[ ! -f "$BASHRC" ]]; then
    touch "$BASHRC"
fi
if grep -qF "$MARKER_BEGIN" "$BASHRC"; then
    echo "  Session-picker hook already present in ~/.bashrc"
else
    {
        echo ""
        echo "$MARKER_BEGIN"
        echo "# Launch the tmux session picker on interactive shell start."
        echo "# tm-login skips when inside tmux, in VS Code, in Guake, or if the picker is absent."
        echo "if [ -x \"$SCRIPT_DIR/bin/tm-login\" ]; then"
        echo "  case \$- in *i*) \"$SCRIPT_DIR/bin/tm-login\" ;; esac"
        echo "fi"
        echo "$MARKER_END"
    } >> "$BASHRC"
    echo "  Added session-picker hook to ~/.bashrc"
fi

# Bootstrap TPM (Tmux Plugin Manager) so the plugins in tmux.conf load.
if command -v git &>/dev/null; then
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" \
            && echo "  Cloned TPM"
    fi
    if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
        tmux start-server 2>/dev/null || true
        "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 \
            && echo "  TPM plugins installed" || true
    fi
else
    echo "  Note: git not found, skipping TPM plugin bootstrap"
fi

# Reload tmux config if tmux is running
if tmux list-sessions &>/dev/null; then
    tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "  Reloaded tmux config" || true
fi

echo ""
echo "  Done. Run 'tm' to see the cheatsheet."
echo ""

# Show cheatsheet
"$SCRIPT_DIR/bin/tm-cheatsheet"
