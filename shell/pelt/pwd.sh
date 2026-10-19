
# Update when directory changes. pelt has no hook on a change of
# directory, so `cd` is a function that records where it went (a function
# is found before a regular built-in, POSIX XCU 2.9.1.4; `command cd` is
# the built-in itself).
cd() {
    command cd "$@" && __lope_hook
}
