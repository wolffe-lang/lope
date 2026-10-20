
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

# Interactive mode: fzf when it is installed, else a numbered menu
function @CMD@i --description "Jump to a directory (interactive)"
    if type -q fzf
        set -l result (command lope query --all -- $argv | fzf --height=40% --reverse)
        if test -n "$result"
            cd $result
        end
        return
    end
    set -l all (command lope query --all -- $argv)
    or return 1
    set -l n (count $all)
    if test $n -gt 9
        set n 9
    end
    for i in (seq $n)
        printf '%s) %s\n' $i $all[$i] >&2
    end
    set -g __lope_reading 1
    read -P "lope: which (1-$n)? " -l pick
    set -l st $status
    set -e __lope_reading
    test $st -eq 0
    or return 1
    if string match -qr '^[1-9]$' -- "$pick"; and test $pick -le $n
        cd $all[$pick]
    else
        return 1
    end
end
