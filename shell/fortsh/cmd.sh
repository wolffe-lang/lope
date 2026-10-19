
# Jump function
@CMD@() {
    if [[ $# -eq 0 ]]; then
        command cd ~ && __lope_hook
    elif [[ $# -eq 1 && "$1" == "-" ]]; then
        command cd - && __lope_hook
    elif [ $# -eq 1 ] && [ -d "$1" ]; then
        command cd "$1" && __lope_hook
    else
        local result
        result=$(command lope query --cwd -- "$@" 2>/dev/null)
        if [[ -z "$result" ]]; then
            result=$(command lope query -- "$@" 2>/dev/null)
        fi
        if [[ -n "$result" ]]; then
            command cd "$result" && __lope_hook
        else
            echo "lope: no match found" >&2
            return 1
        fi
    fi
}

# Interactive mode with fzf
@CMD@i() {
    local result
    result=$(command lope query --all -- "$@" | fzf --height=40% --reverse)
    if [[ -n "$result" ]]; then
        command cd "$result" && __lope_hook
    fi
}
