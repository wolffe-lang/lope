
# Jump function
@CMD@() {
    if [ $# -eq 0 ]; then
        command cd ~ && __lope_hook
    elif [ $# -eq 1 ] && [ "$1" = "-" ]; then
        command cd - && __lope_hook
    elif [ $# -eq 1 ] && [ -d "$1" ]; then
        command cd -- "$1" && __lope_hook
    else
        __lope_result=$(command lope query --cwd -- "$@" 2>/dev/null)
        if [ -z "$__lope_result" ]; then
            __lope_result=$(command lope query -- "$@" 2>/dev/null)
        fi
        if [ -n "$__lope_result" ]; then
            command cd -- "$__lope_result" && __lope_hook
        else
            echo "lope: no match found" >&2
            return 1
        fi
    fi
}

# Interactive mode: fzf when it is installed, else a numbered menu
@CMD@i() {
    if command -v fzf >/dev/null 2>&1; then
        __lope_result=$(command lope query --all -- "$@" | fzf --height=40% --reverse)
    else
        __lope_result=$(__lope_menu "$@")
    fi
    if [ -n "$__lope_result" ]; then
        command cd -- "$__lope_result" && __lope_hook
    fi
}
