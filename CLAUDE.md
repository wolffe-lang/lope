# lope — agent guidance

A frecency directory jumper in pure wolf: gump (tenseleyFlow/gump, the
maintainer's) ported and renamed (Track 13, ruling #91). The planning
repo's `sprints/lope/index.md` holds the track's rules; this is them in
brief.

## The clean-room rule (read before writing a line)

- gump is the maintainer's: read it at `gump.pin` and cite `file:line`.
  `src/matcher/fuzzy.rs` is read for its interface only, never a function
  body (it wraps nucleo).
- **Never read the source of nucleo, fzf, skim, zoxide, autojump, z or
  fasd**, nor search for it. The matcher is lope's own; its constants come
  from probes of the gump binary (`tests/oracle/probes.jsonl`). The
  importers read the other tools' DATA, as gump's importer states each
  format (`tests/import/FORMATS.md`), never their code.
- No dependency but wolf-std.

## Every behaviour claim is a test

| claim | gate |
|---|---|
| the matcher's numbers | `src/matcher_test.lu` (wolf test, and lupin), `tools/probe-check` (322 rows) |
| landing where gump lands | `tools/oracle-check` (654 cases; floor `tests/oracle/FLOOR`, never lowered) |
| folding | `tools/fold-check` (floor `tests/oracle/FOLD-FLOOR`) |
| frecency, aging, the codec, db.bin | `src/db_test.lu` |
| gump's messages and statuses | `tools/cli-check` (95 recorded command lines) |
| the hooks | `tools/hook-sessions` on PTYs, `tests/hooks/expected.tsv` (pelt at `pelt.pin`) |
| the store's syncs | `tools/sync-census` (strace; the calls in order, four failures injected, the cost) |
| import, edit | `tools/import-check`, `tools/edit-check` |
| speed | `tools/speed` (query no slower than gump) |
| each harness can go red | `tools/selftest` |

A new gate is seen red before it is trusted (a planted break in CI).
Recording needs the gump binary and happens on kasumi
(`tools/oracle-record`, `tools/cli-record`); CI replays the records.

## Hosts and toolchains

wolf, lupin and wolf-std from release archives by digest
(`wolf-toolchain.toml`, `tools/fetch-toolchain`). Build and test on kasumi
or hasu, never on nomad-1. Hook sessions run only on PTYs the tool starts,
with scratch `HOME` and `XDG_*` directories. The static build
(`tools/mkstatic`) runs on a baseline glibc (an Ubuntu container), for PAX.

## No silent stub

What wolf cannot do yet is named where the reader meets it, with its
issue: paths are `str`, so a non-UTF-8 path cannot be stored
(wolf-lang#687). lupin 0.1.55 resolves neither `fs_sync` nor
`fs_sync_dir` (wolf-interp#268): it refuses at the call, and no test it
runs saves the store (`wolf-toolchain.toml`).

## Commits, PRs

No attribution trailers. Terse imperative commits, one per file or chunk.
CI is tiered (`ci/tiers.py`): a PR runs `tier pr`; the `full-matrix` label,
added at the final head, runs `tier full`, which a merge needs.
