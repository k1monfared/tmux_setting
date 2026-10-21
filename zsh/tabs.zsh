# Plain-terminal tab title (Terminal.app etc.). Inside tmux, tmux.conf owns the
# title, so this does nothing there. Marks come from bin/tab-mark.
[[ -n "$TMUX" ]] && return 0

_tab_mark_file() { print -r -- "${TMPDIR:-/tmp}/tab-mark-$(id -u)/${$(tty):t}"; }

# Prompt returned => any agent that set a mark has exited: drop the stale dot.
_tab_precmd() {
    local f; f="$(_tab_mark_file)"; [[ -e $f ]] && rm -f -- "$f"
    print -Pn '\e]0;%1~\a'
}
# A command started: show it in the title like the tmux config does for non-shell panes.
_tab_preexec() { print -Pn "\e]0;%1~ : ${1%% *}\a" }

autoload -Uz add-zsh-hook
add-zsh-hook precmd  _tab_precmd
add-zsh-hook preexec _tab_preexec
