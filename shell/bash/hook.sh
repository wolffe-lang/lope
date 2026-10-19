
# lope hook - called after directory changes
__lope_hook() {
    __lope_oldpwd="$PWD"
    command lope add -- "$PWD"
}
