
# Update on every prompt
function __lope_hook --on-event fish_prompt
    command lope add -- $PWD
end
