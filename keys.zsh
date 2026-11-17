# keys.zsh: a cheat sheet for zsh command-line shortcuts.
#
# Reads your shell's own key bindings (via `bindkey`), so the keys shown
# are the ones that actually work on your machine.
#
# Usage:
#   keys           show the cheat sheet
#   keys <word>    show only the lines containing <word>
#   Option+K       open it while typing (live-filtered if fzf is installed)
#
# Install: add this line to ~/.zshrc
#   source /path/to/keys.zsh
#
# Settings (set before the source line):
#   KEYS_HOTKEY    hotkey in bindkey notation (default '^[k', Option+K)
#
# Requires zsh. Optional: fzf, for live filtering.

# Only meaningful in an interactive zsh; do nothing anywhere else.
[[ -n $ZSH_VERSION && -o interactive ]] || return 0

# Hotkey in bindkey notation. Set KEYS_HOTKEY before sourcing to change it.
: ${KEYS_HOTKEY:='^[k'}

# The actions worth showing, each with a plain-English description
_keys_list=(
  "beginning-of-line|Jump to start of line"
  "end-of-line|Jump to end of line"
  "backward-kill-word|Delete the word before the cursor"
  "backward-word|Move back one word"
  "forward-word|Move forward one word"
  "kill-line|Delete the text following the cursor"
  "kill-whole-line|Delete the whole line"
  "history-incremental-search-backward|Search command history as you type"
  "clear-screen|Clear the screen"
  "undo|Undo the last edit"
  "yank|Paste back deleted text"
  "_keys_widget|Show this cheat sheet"
)

# Print the friendliest key bound to an action, e.g. _keys_lookup kill-line
_keys_lookup() {
  local action=$1 line key best
  for line in ${(f)"$(bindkey)"}; do
    if [[ ${line##* } == "$action" ]]; then
      key=${line% *}
      if [[ -z $best ]] || (( ${#key} <= ${#best} )); then
        best=$key
      fi
    fi
  done
  print -r -- $best
}

# Turn bindkey notation into readable keys, e.g. "^[b" -> Option+B
_keys_pretty() {
  local key=$1 shift= prefix=
  key=${key#\"}
  key=${key%\"}
  if [[ $key == '^X'?* ]]; then
    prefix='Ctrl+X, then '
    key=${key#\^X}
  fi
  [[ $key == '^['[A-Z] ]] && shift=Shift+
  key=${(U)key}
  key=${key//\^\[/Option+$shift}
  key=${key//\^\?/Backspace}
  key=${key//\^/Ctrl+}
  print -r -- $prefix$key
}

# keys [word]: print the cheat sheet, optionally only lines containing word
keys() {
  local entry action desc key
  for entry in $_keys_list; do
    action=${entry%%|*}
    desc=${entry#*|}
    key=$(_keys_pretty "$(_keys_lookup $action)")
    [[ -n $key ]] || continue
    printf '%-12s %s\n' "$key" "$desc"
  done | grep -i -- "$*"
}

# Widget: live-filterable cheat sheet if fzf exists, plain list if not
_keys_widget() {
  if command -v fzf >/dev/null; then
    zle -I
    keys | fzf --no-sort --height=40% --reverse --prompt='keys> ' >/dev/null
    zle reset-prompt
  else
    zle -M "$(keys)"
  fi
}
zle -N _keys_widget
bindkey "$KEYS_HOTKEY" _keys_widget
