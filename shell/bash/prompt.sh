
# Update on every prompt
if [[ "${PROMPT_COMMAND:-}" != *'__lope_hook'* ]]; then
    PROMPT_COMMAND="__lope_hook;${PROMPT_COMMAND#;}"
fi
