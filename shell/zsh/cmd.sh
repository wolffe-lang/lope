
# Jump function
@CMD@() {
    if [[ $# -eq 0 ]]; then
        builtin cd ~
    elif [[ $# -eq 1 && "$1" == "-" ]]; then
        builtin cd -
    elif [[ $# -eq 1 && -d "$1" ]]; then
        # Explicit path - cd directly without fuzzy matching
        builtin cd -- "$1"
    else
        local result
        # Try CWD first, then database
        result=$(command lope query --cwd -- "$@" 2>/dev/null)
        if [[ -z "$result" ]]; then
            result=$(command lope query -- "$@" 2>/dev/null)
        fi
        if [[ -n "$result" ]]; then
            builtin cd -- "$result"
        else
            echo "lope: no match found" >&2
            return 1
        fi
    fi
}

# Interactive mode: fzf when it is installed, else a numbered menu
@CMD@i() {
    local result
    if command -v fzf >/dev/null 2>&1; then
        result=$(command lope query --all -- "$@" | fzf --height=40% --reverse)
    else
        result=$(__lope_menu "$@")
    fi
    if [[ -n "$result" ]]; then
        builtin cd -- "$result"
    fi
}
