
# Jump function
function @CMD@ --description "Jump to a directory"
    if test (count $argv) -eq 0
        cd ~
    else if test (count $argv) -eq 1 -a "$argv[1]" = "-"
        cd -
    else if test (count $argv) -eq 1 -a -d "$argv[1]"
        # Explicit path - cd directly without fuzzy matching
        cd $argv[1]
    else
        # Try CWD first, then database
        set -l result (command lope query --cwd -- $argv 2>/dev/null)
        if test -z "$result"
            set result (command lope query -- $argv 2>/dev/null)
        end
        if test -n "$result"
            cd $result
        else
            echo "lope: no match found" >&2
            return 1
        end
    end
end

# Interactive mode with fzf
function @CMD@i --description "Jump to a directory (interactive)"
    set -l result (command lope query --all -- $argv | fzf --height=40% --reverse)
    if test -n "$result"
        cd $result
    end
end
