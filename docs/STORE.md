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

**Written atomically and durably** (ruling #96 D9; wolf 0.2.34's
`[os.fs.sync]`, its five calls): the whole store goes to `store.tmp.PID`
beside it, created exclusively (open mode 4); that file is synced
(`fs_sync`: `fsync(2)` on linux, `F_FULLFSYNC` on macOS) and closed, then
renamed over the store, and the directory is synced (`fs_sync_dir`). A
reader sees the old store or the new one, never half of either; a crash or
a power loss at any point leaves one of the two whole, since the first sync
puts the new bytes on the disk before a name points at them and the second
puts the rename there. gump syncs the file and not the directory
(`store.rs:129`). A `store.tmp.PID` already there is an earlier process's
with the same pid, which ended between its create and its rename: it is
removed and the create made again.

A save that fails leaves no temporary file and the old store, and says the
reason of the step that failed (`lope: I/O error: TEXT (os error N)`, status
1). The directory's sync is the one step after the rename: when it fails,
the new store is already in place, and lope still says the save failed,
since the rename may not survive a crash. `tools/sync-census` shows the
calls in their order under strace and injects a failure at the write, at
each sync and at the rename; CI runs it on both tiers.

**The cost, stated:** the two syncs are the whole of it, one call each.
A save is what the hook's `lope add` does on every `cd`; `query`, `list`
and `init` write nothing, so the speed gate (`query`) does not move.
Measured (lp01, `tools/sync-census`, `notes/lp01-evidence/cost/`):

| where | the file's sync | the directory's | `lope add` | without the syncs | per save |
|---|---|---|---|---|---|
| kasumi, btrfs on nvme, load about 3 | 4.97 ms | 4.94 ms | 10.40 ms | 0.82 ms | +9.6 ms |
| kasumi, the same, load 8–12 (other jobs writing), five runs | 6.2–11.7 ms | 9.7–15.0 ms | 18.1–43.9 ms | 1.4–2.3 ms | +16.6 to +42.4 ms |
| CI's runner, ext4 | 0.43–0.47 ms | 0.22–0.23 ms | 2.03–2.06 ms | | about +0.7 ms |

Each sync's time is `strace -T`'s, the median of the census's saves;
`lope add` is the median of 15 or 31 fresh processes under `taskset -c
0-3`, interleaved with the same lope built without the syncs. gump's `add`
syncs the file only: on kasumi, loaded, lope's took 20.0 and 31.0 ms
against gump's 10.9 and 15.6 (interleaved, 31 runs each), about one sync
more. On tmpfs, and in PAX's in-memory tree (which answers 0 to a sync of a
file or a directory, pax `kernel/files/files.lu:4437`), a sync costs
nothing.

**gump's `db.bin`** is read by `lope import` (`src/db/gump.lu`): bincode
1's documented encoding (fixed-width little-endian integers, a `u64` length
before every string and map) of gump's `DatabaseFile` and `DirEntry`,
checked against a file gump 0.2.7 wrote. Every score, visit count and time
is kept.
