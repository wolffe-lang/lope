# The importers' fixtures

Each file was written by hand from the format as gump's own importer
states it (the maintainer's `src/cmd/import.rs` at `43c114d`, its comments
and parsers), never from the other tools' source (ruling #91 R3).
`$ROOT` is the scratch directory tools/import-check makes; the
directories it names exist there, except `missing-dir` and `gone-now`,
and `a-file.txt` is a file.

| file | tool | format | gump |
|---|---|---|---|
| `autojump.txt` | autojump | `WEIGHT<TAB>PATH` per line, at `$XDG_DATA_HOME/autojump/autojump.txt` | `import.rs:97–107` |
| `z.txt` | z, z.lua, zsh-z | `PATH|RANK|TIME` per line, at `~/.z`, `$_Z_DATA`, `$Z_DATA`, `$ZSHZ_DATA` | `import.rs:130–155` |
| `fasd.txt` | fasd | `PATH|RANK|TIME` per line, files and directories alike, at `~/.fasd` | `import.rs:181–202` |
| `zoxide-query.txt` | zoxide | what `zoxide query --list --score` prints: blanks, a score, a space, the path | `import.rs:66–68`, `:217` |
| `gump.json` | gump | entries for gump's own `db.bin`, written by tools/gumpdb.py in bincode 1's layout | `store.rs:35`, `entry.rs:6` |

zoxide is not installed on kasumi (and the rules forbid installing it), so
its output could not be observed: tools/import-check puts a `zoxide` on
`PATH` that prints `zoxide-query.txt`, which is the line shape gump's
parser accepts.
