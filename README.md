# tm: tmux session manager

**Status**: 🔴 POC | **Mode**: 🤖 Claude Code | **Updated**: 2026-04-07

Easy tmux session management with `tm` shell commands and `Ctrl+T` in-session keybindings. Includes an interactive fzf session picker.

## Install

```bash
git clone <repo> ~/public/tmux_setting
cd ~/public/tmux_setting
bash install.sh
```

This symlinks `~/.tmux.conf` and adds `tm` to `~/.local/bin/`.

## Uninstall

```bash
bash uninstall.sh
```

## Shell Commands

| Command | Description |
|---------|-------------|
| `tm` | Show cheatsheet |
| `tm n [name]` | New session |
| `tm p` | Interactive session picker |
| `tm a [name]` | Attach to session |
| `tm l` | List all sessions |
| `tm k [name]` | Kill a session |
| `tm ka` | Kill all sessions |
| `tm r [name]` | Rename session |
| `tm d` | Detach |
| `tm w` | List windows |

## In-Session Keybindings

Prefix: `Ctrl+T` (replaces default `Ctrl+B`)

| Keybinding | Action |
|-----------|--------|
| `Ctrl+T r` | Rename session |
| `Ctrl+T d` | Detach |
| `Ctrl+T \` | Split left/right |
| `Ctrl+T -` | Split top/bottom |
| `Ctrl+T x` | Close pane |
| `Ctrl+T z` | Zoom/unzoom pane |
| `Ctrl+T Space` | Cycle layouts |
| `Ctrl+T c` | New window |
| `Ctrl+T ,` | Rename window |
| `Ctrl+T n` | Next window |
| `Ctrl+T p` | Previous window |
| `Ctrl+T 0-9` | Switch to window # |
| `Ctrl+T [` | Copy/scroll mode |
| `Ctrl+T ?` | Show all keybindings |
| `Ctrl+T Ctrl+S` | Save all sessions (auto-saves every 15 min) |
| `Ctrl+T Ctrl+R` | Restore saved sessions |

No prefix needed:

| Keybinding | Action |
|-----------|--------|
| `Ctrl+Arrows` | Move between panes |
| `Alt+Arrows` | Resize pane |
| `Mouse/Touchpad` | Scroll terminal history |

## Notes

- `Ctrl+T Ctrl+T` sends a literal Ctrl+T to the terminal
- Alt+Arrows is used for resize instead of Fn+Arrows (Fn+Arrow sends Home/End/PgUp/PgDn on most Linux terminals)
- Mouse/touchpad scrolling goes through terminal history instead of cycling through shell commands

## Dependencies

- tmux 3.4+
- fzf 0.44+
- bash

## Documentation

- `STATUS.log` - Project status and progress tracking
- `data/` - Data files defining commands, keybindings, and cheatsheet content
