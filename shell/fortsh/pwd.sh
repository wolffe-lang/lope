
# Track directory changes
__lope_oldpwd="$PWD"
__lope_pwd_hook() {
    if [[ "$PWD" != "$__lope_oldpwd" ]]; then
        __lope_oldpwd="$PWD"
        __lope_hook
    fi
}
