
# lope hook - called after directory changes
__lope_hook() {
    command lope add -- "$PWD"
}
