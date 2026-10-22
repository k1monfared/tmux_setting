# Short prompt: "dir $", Catppuccin Mocha colors (blue dir, mauve $).
# Terminal.app has no truecolor; nearcolor maps the hex values to 256 colors.
zmodload zsh/nearcolor 2>/dev/null
PROMPT='%F{#89b4fa}%1~%f %F{#cba6f7}$%f '
