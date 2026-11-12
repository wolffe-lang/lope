# Contributing to lope

lope is a frecency directory jumper written in
[wolf](https://github.com/wolffe-lang/wolf-lang): type fragments of a
directory's path and land where you meant. It is
[gump](https://github.com/tenseleyFlow/gump) 0.2.7 ported and renamed, with a
matcher of its own, a hook for [pelt](https://github.com/wolffe-lang/pelt) so
it runs on PAX, and its speed held to gump's in CI.

## What may be read

- **gump may be read**, at the commit `gump.pin` names: it is MIT-licensed and
  has the same owner as lope. Cite the `file:line` a port comes from. gump's
  `src/matcher/fuzzy.rs` wraps a third party's matcher, so read it for its
  interface only, never a function body.
- **Never read the source of nucleo, fzf, skim, zoxide, autojump, z or fasd**,
  nor search for it. The matcher is lope's own (`docs/MATCHER.md`); its
  constants come from probes of the gump binary (`tests/oracle/probes.jsonl`).
  The importers read the other tools' data formats as gump's importer states
  them (`tests/import/FORMATS.md`), never their code.
- No dependency but wolf-std.

## The toolchain

`wolf-toolchain.toml` pins the wolf compiler and the lupin interpreter by the
sha256 digest of their release archives, and wolf-std as a tree at a commit.

```sh
tools/fetch-toolchain    # stages all three into .wolf-bin/
tools/fetch-gump         # gump at gump.pin, built into .gump/ (for the speed gate)
tools/fetch-pelt         # pelt at pelt.pin, built into .pelt/ (for pelt's hook sessions)
```

A pin moves in a commit of its own.

## Building and running the checks

```sh
tools/build                       # target/native/lope and target/release/lope
tools/check-fmt                   # wolf fmt --check
tools/check-test                  # the unit tests (`wolf test`)
tools/probe-check target/release/lope
tools/oracle-check target/release/lope
tools/selftest target/release/lope
python3 ci/tiers-test.py          # CI's planner against its rules
```

Every behaviour claim has a gate:

| claim | gate |
|---|---|
| the matcher's numbers | `src/matcher_test.lu` (`wolf test`, and lupin), `tools/probe-check` |
| landing where gump lands | `tools/oracle-check` (its floor, `tests/oracle/FLOOR`, is never lowered) |
| folding | `tools/fold-check` (floor `tests/oracle/FOLD-FLOOR`) |
| frecency, aging, the codec, the store | `src/db_test.lu` |
| gump's messages and statuses | `tools/cli-check` |
| the shell hooks | `tools/hook-sessions` on pseudo-terminals, `tests/hooks/expected.tsv` |
| the store's syncs | `tools/sync-census` (Linux, strace) |
| import, edit | `tools/import-check`, `tools/edit-check` |
| speed | `tools/speed` (a query no slower than gump's) |
| each harness can go red | `tools/selftest` |

`tools/hook-sessions` runs the hooks only in shells it starts on its own
pseudo-terminals, each with a scratch `HOME` and `XDG_*` directories, never
your own shell's configuration or data. The static build for PAX
(`tools/mkstatic`) runs on a baseline glibc, such as an Ubuntu container.

## What a change must bring

- Each behaviour claim comes with its gate, as in the table above. A new gate
  is seen red before it is trusted: plant a break in a commit of its own, let
  CI show it red, then fix it.
- The oracle's answers are recorded from the gump binary
  (`tools/oracle-record`, `tools/cli-record`) and committed; CI replays the
  records with no gump present. Re-record only with gump built at the pin.
- No silent stub: what wolf cannot do yet is named, with its upstream issue,
  where a reader meets it, and refused rather than faked. A gap in wolf is
  filed upstream at [wolffe-lang/wolf-lang](https://github.com/wolffe-lang/wolf-lang)
  with a small program that shows it.
- A user-visible change gets an entry under `## Unreleased` in `CHANGELOG.md`.

## Commits

- Terse, imperative subjects, one file or one coherent change a commit. Stage
  what you mean, never `git add -A`.
- No trailers: no co-author, sign-off or "generated with" lines.

## Pull requests

Open a pull request from a branch against `trunk`. An unlabelled pull request
runs only a cheap check, so your own run of the checks is the evidence: the
description names the head you ran them on and their results. A change to CI,
`tools/` or a pin also needs the full CI set green at its head before it
merges: ask for the `full-matrix` label once the head is the one to merge, not
when the pull request opens.
