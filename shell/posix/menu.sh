
# A numbered menu of the best matches, for when fzf is not installed (and
# on PAX, which has none): at most nine, chosen by one digit read from the
# terminal; the chosen directory is printed. Shell built-ins and lope only.
__lope_menu() {
    command lope query --all -- "$@" >/dev/null 2>&1 || return 1
    command lope query --all -- "$@" | {
        __lope_n=0
        while [ "$__lope_n" -lt 9 ] && IFS= read -r __lope_line; do
            __lope_n=$((__lope_n + 1))
            printf '%s) %s\n' "$__lope_n" "$__lope_line" >&2
        done
    }
    printf 'lope: which? ' >&2
    read -r __lope_pick || return 1
    # (`:` in the arm: fortsh 1.10.0 stops at an empty case arm)
    case $__lope_pick in
    [1-9]) : ;;
    *) return 1 ;;
    esac
    command lope query --all -- "$@" | {
        __lope_n=0
        while IFS= read -r __lope_line; do
            __lope_n=$((__lope_n + 1))
            if [ "$__lope_n" -eq "$__lope_pick" ]; then
                printf '%s\n' "$__lope_line"
                break
            fi
        done
    }
}
