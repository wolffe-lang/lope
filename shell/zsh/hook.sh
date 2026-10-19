
# lope hook - called after a directory change
__lope_hook() {
    command lope add -- "$PWD"
}
