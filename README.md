# tm: tmux session manager

**Status**: 🔴 POC | **Mode**: 🤖 Claude Code | **Updated**: 2026-09-16

Easy tmux session management with `tm` shell commands and `Ctrl+T` in-session keybindings. Includes an interactive fzf session picker.

## Install

```bash
git clone <repo> ~/public/tmux_setting
cd ~/public/tmux_setting
bash install.sh --profile laptop    # or: server, phone
```

This symlinks `~/.tmux.conf`, symlinks the chosen profile to `~/.tmux.conf.local`, adds `tm` and `tm-clip` to `~/.local/bin/` (`tm` goes to `$PREFIX/bin` on Termux), and adds a marker-delimited hook to `~/.bashrc` that launches the session picker on interactive shell start. With git available it also bootstraps TPM and its plugins.

## Profiles

The shared config (`conf/tmux.conf`) is role-agnostic. Machine-specific settings live in `conf/profiles/` and are symlinked to `~/.tmux.conf.local` at install time, so a `git pull` updates the profile too:

| Profile | Intended machine | Status bar |
|---------|------------------|------------|
| `laptop` | graphical workstation | hostname, green |
| `server` | always-on headless machine over ssh | hostname, magenta |
| `phone` | Termux on Android | "phone", cyan |

A profile can override anything from the shared config: `@machine_label`, `@machine_color`, `@enable_plugins`, scrollback, and so on. `install.sh` picks `phone` automatically on Termux and `laptop` elsewhere when `--profile` is omitted.

## Session picker on shell start

New interactive shells run `bin/tm-login`, which shows the session picker. It drops straight to a plain shell (no picker) when any of these hold:

- already inside a tmux session (`$TMUX` set)
- VS Code integrated terminal (`TERM_PROGRAM=vscode`)
- Guake drop-down terminal (`GUAKE_TAB_UUID` set)
- the picker binary is not installed

`bin/tm-login` is the single source of truth for these skip rules. To exclude another terminal, add a check there.

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
- Copy-mode bindings (Enter / M-w, double/triple click) pipe to `tm-clip`, which copies with whichever tool the machine has: `xclip` (X11), `wl-copy` (Wayland), `termux-clipboard-set` (Termux with termux-api), `pbcopy` (macOS). Without any of them the selection stays in the tmux buffer, paste with `Ctrl+T ]`
- On Termux the status bar shows "phone" instead of the Termux hostname "localhost"

## Dependencies

- tmux 3.4+
- bash
- Optional: fzf 0.44+ (for `tm pick`), python3 (for the login picker), git (for TPM plugin bootstrap and plugins)
- Linux: `sudo apt install tmux fzf` · Termux: `pkg install tmux fzf git python`

## Documentation

- `STATUS.log` - Project status and progress tracking
- `conf/profiles/` - per-machine settings symlinked to `~/.tmux.conf.local`
- `data/` - Data files defining commands, keybindings, and cheatsheet content
