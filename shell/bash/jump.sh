
# No-prefix directory jumping
command_not_found_handle() {
    # Check if it's a local directory first (exact match)
    if [[ -d "$1" ]]; then
        builtin cd -- "$1" && __lope_hook
        return 0
    fi

    # Fuzzy match against current directory contents
    local result
    result=$(command lope query --cwd -- "$@" 2>/dev/null)
    if [[ -n "$result" ]]; then
        builtin cd -- "$result" && __lope_hook
        return 0
    fi

    # Query lope database
    result=$(command lope query -- "$@" 2>/dev/null)
    if [[ -n "$result" ]]; then
        builtin cd -- "$result" && __lope_hook
        return 0
    fi

    # Fallback to default "command not found" behavior
    echo "bash: $1: command not found" >&2
    return 127
}
