
# Update when directory changes
function __lope_hook --on-variable PWD
    command lope add -- $PWD
end
