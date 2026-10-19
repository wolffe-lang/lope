
# No-prefix directory jumping. bash runs command_not_found_handle in a
# subshell, where a cd cannot reach the shell (gump's hook stays put), so
# lope reads the line when Enter is pressed instead, as the zsh and fish
# hooks do: a first word that is no alias, keyword, function, built-in or
# command, and is a directory here or matches one, becomes `cd -- DIR`
# before bash reads the line. bash 4 or later, interactive.
__lope_accept_line() {
    local -a words
    read -r -a words <<<"$READLINE_LINE"
    local first="${words[0]}"
    [[ -z "$first" ]] && return 0
    [[ "$first" == [./~]* ]] && return 0
    type -t -- "$first" >/dev/null 2>&1 && return 0
    local result
    if [[ -d "$first" ]]; then
        result="$first"
    else
        result=$(command lope query --cwd -- "${words[@]}" 2>/dev/null)
        if [[ -z "$result" ]]; then
            result=$(command lope query -- "${words[@]}" 2>/dev/null)
        fi
    fi
    if [[ -n "$result" ]]; then
        printf -v READLINE_LINE 'cd -- %q' "$result"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

if [[ $- == *i* ]] && ((BASH_VERSINFO[0] >= 4)); then
    for __lope_map in emacs vi-insert vi-command; do
        bind -m "$__lope_map" -x '"\C-x\C-_": __lope_accept_line'
        bind -m "$__lope_map" '"\C-x\C-^": accept-line'
        bind -m "$__lope_map" '"\C-m": "\C-x\C-_\C-x\C-^"'
        bind -m "$__lope_map" '"\C-j": "\C-x\C-_\C-x\C-^"'
    done
    unset __lope_map
fi
