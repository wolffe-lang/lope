
# No-prefix directory jumping. pelt cc2fdc9 calls no function when a
# command is not found (it says `NAME: not found` and the status is 127);
# this is the function lope asks pelt to call then, in the shell's own
# environment, with the command's words: it changes directory and answers
# 0, or answers 127 and pelt says what it always says (sh21).
command_not_found_handle() {
    if [ -d "$1" ]; then
        command cd -- "$1" && __lope_hook
        return 0
    fi
    __lope_result=$(command lope query --cwd -- "$@" 2>/dev/null)
    if [ -z "$__lope_result" ]; then
        __lope_result=$(command lope query -- "$@" 2>/dev/null)
    fi
    if [ -n "$__lope_result" ]; then
        command cd -- "$__lope_result" && __lope_hook
        return 0
    fi
    return 127
}
