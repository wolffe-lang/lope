
# No-prefix directory jumping via Enter key interception
function __lope_execute
    # Enter inside `read` is that read's own answer, never a command line
    # to rewrite: gi's menu says it is reading; a `read` typed at the
    # prompt is the current command
    if set -q __lope_reading; or test (status current-command) = read
        commandline -f execute
        return
    end

    set -l cmd (commandline -b)
    set -l first_word (string split ' ' -- $cmd)[1]

    # Skip if empty
    if test -z "$first_word"
        commandline -f execute
        return
    end

    # Skip if command exists
    if type -q "$first_word"
        commandline -f execute
        return
    end

    # Skip if starts with path characters
    if string match -qr '^[./~]' -- "$first_word"
        commandline -f execute
        return
    end

    # Check if it's a local directory (exact match)
    if test -d "$first_word"
        commandline -r "cd $first_word"
        commandline -f execute
        return
    end

    # Fuzzy match against current directory contents
    set -l result (command lope query --cwd -- $cmd 2>/dev/null)
    if test -n "$result"
        commandline -r "cd \"$result\""
        commandline -f execute
        return
    end

    # Query lope database
    set -l result (command lope query -- $cmd 2>/dev/null)
    if test -n "$result"
        commandline -r "cd \"$result\""
        commandline -f execute
        return
    end

    # Not a lope match, execute normally
    commandline -f execute
end

bind \r __lope_execute
bind \n __lope_execute
