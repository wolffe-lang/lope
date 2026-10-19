# The store

lope's own format, version 1, at `$LOPE_DATA_DIR/store` (by default
`$XDG_DATA_HOME/lope/store`, else `$HOME/.local/share/lope/store`; `/`
stands in for an unset `HOME`). Text, so it can be read, diffed and fixed
by hand:

    lope-store 1
    cleanup 1760900000000
    12.500000 1760899000000 13 /home/u/code/projects

- Line 1 is the version. A store whose first line is anything else is
  refused (`lope: FILE: line 1 is not a lope store line`), never guessed at.
- Line 2 is the last `clean`, in Unix milliseconds.
- Every other line is one directory: the raw score with six decimals, the
  last visit (Unix milliseconds), the number of visits and the path,
  separated by single spaces. The path is last, so it may hold spaces; a
  backslash, a newline and a carriage return in it are written `\\`, `\n`
  and `\r`.

The rule is gump's (`src/db/entry.rs`, `src/db/store.rs` at `43c114d`): a
visit adds one to the raw score (a new directory starts at one); frecency
is the raw score ×4 when the last visit was within the hour, ×2 within the
day, ×½ within the week and ×¼ after (whole hours, truncated); when the
total raw score passes `LOPE_MAXAGE` (10,000), every score is divided by
`total / (max × 0.9)` and those left under one are dropped; `clean` drops a
directory that no longer exists and was last visited more than 90 whole
days ago. Raw scores are kept in millionths (gump keeps an `f64`).

**Written atomically:** the whole store goes to `store.tmp.PID` beside it,
which is then renamed over it, so a reader sees the old store or the new
one, never half of either. **What wolf cannot do, named:** wolf 0.2.33 has
no `fsync`, so the temporary file is not synced before the rename as
gump's is (`store.rs:129`); a power loss after the rename can lose the last
write on a filesystem that reorders the two (a wolf-lang issue to file).

**gump's `db.bin`** is read by `lope import` (`src/db/gump.lu`): bincode
1's documented encoding (fixed-width little-endian integers, a `u64` length
before every string and map) of gump's `DatabaseFile` and `DirEntry`,
checked against a file gump 0.2.7 wrote. Every score, visit count and time
is kept.
