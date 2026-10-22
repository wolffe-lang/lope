
# Turn on pelt 2dc8dbe's interactive directory-word path. Older pelts
# reject this non-POSIX option; suppress that diagnostic and keep evaluating
# their interactive init text.
set -o autocd 2>/dev/null || :

# lope hook - called after directory changes
__lope_hook() {
    command lope add -- "$PWD"
}
