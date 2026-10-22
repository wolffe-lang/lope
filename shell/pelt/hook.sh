
# Turn on pelt 2dc8dbe's interactive directory-word path.  Older pelts
# abort on an unknown `set -o` option, even on the left of `||`, so keep it
# in a subshell: a failed old-pelt option exits only that subshell.
(set -o autocd) 2>/dev/null || :

# lope hook - called after directory changes
__lope_hook() {
    command lope add -- "$PWD"
}
