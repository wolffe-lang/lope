
# Update on every prompt: pelt expands PS1 before each prompt (XCU 2.5.3),
# command substitutions included, so the hook runs there.
case ${PS1-} in
*__lope_hook*) ;;
*) PS1='$(__lope_hook)'"${PS1-\$ }" ;;
esac
