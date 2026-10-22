
# Turn on pelt 2dc8dbe's interactive directory-word path. Older pelts
# reject this non-POSIX option as a fatal special builtin, so probe in a
# subshell first; set it in this shell only when the probe succeeded.
if (set -o autocd) 2>/dev/null; then
    set -o autocd
fi

# lope hook - called after directory changes
__lope_hook() {
    command lope add -- "$PWD"
}
