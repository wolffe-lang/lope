
# ZLE widget to intercept commands before execution
__lope_accept_line() {
    local first_word="${BUFFER%% *}"

    # Skip if buffer is empty
    if [[ -z "$BUFFER" ]]; then
        zle .accept-line
        return
    fi

    # Skip paths (starting with . / or ~)
    if [[ "$first_word" == "."* ]] || \
       [[ "$first_word" == "/"* ]] || \
       [[ "$first_word" == "~"* ]]; then
        zle .accept-line
        return
    fi

    # Skip if command exists (whence checks builtins, functions, aliases, and PATH)
    if whence "$first_word" >/dev/null 2>&1; then
        zle .accept-line
        return
    fi

    # Check if it's a local directory (exact match)
    if [[ -d "$first_word" ]]; then
        BUFFER="cd ${(q)first_word}"
        zle .accept-line
        return
    fi

    # Fuzzy match against current directory contents
    local result
    result=$(command lope query --cwd -- $=BUFFER 2>/dev/null)
    if [[ -n "$result" ]]; then
        BUFFER="cd ${(q)result}"
        zle .accept-line
        return
    fi

    # Query lope database
    result=$(command lope query -- $=BUFFER 2>/dev/null)
    if [[ -n "$result" ]]; then
        BUFFER="cd ${(q)result}"
    fi

    zle .accept-line
}

zle -N accept-line __lope_accept_line
