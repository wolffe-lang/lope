# lp00 — the port: lope, gump in wolf

Contract: `sprints/lope/lp00-the-port.md` in the planning repo (`wolf`,
trunk `434ebd8`; ruling #91 R4 added at `700c3e0`, read before the first
change). This file is the lane's record. §1 to §3 are committed before
the first line under `src/`, `tools/` or `tests/`; §4 (the evidence
index) and §5 (done-when) are filled in as the work lands.

## 1. Forbidden

As the contract and the track's standing rules 1–6. gump (the
maintainer's, MIT) is read and cited by `file:line` at `43c114d`;
`src/matcher/fuzzy.rs` only for its interface (`Match`, `score`,
`rank`, the doc comments and the tests' assertions) and never for a
function body. No source of nucleo, fzf, skim, zoxide, autojump, z or
fasd is read or searched for; their *data formats* only, observed or
documented, and the gump binary as a black box. The matcher's
constants come from probes of the gump binary, each probe row kept in
the tree. No dependency but wolf-std. Builds and runs on kasumi (and
hasu), never on nomad-1; the maintainer's gump clone on nomad-1 is
read-only (the lane clones at the pin). Hook sessions only on PTYs the
test starts, with a scratch `HOME` and `XDG_*` directories. Toolchains
from release archives by digest, each read twice. No merge, no tag, no
issue filed or closed (listed in the report), nothing published, none
of gump's packages touched, the repo stays private. No attribution
trailers. `setsid` with a pid file for long jobs; kill by recorded pid
only. If the harness refuses an action, the lane stops and reports.

## 2. Inputs, verified (2026-10-19)

| input | contract says | measured | drift |
|---|---|---|---|
| planning trunk | `434ebd8` | `434ebd8` (lp00 contract); `700c3e0` adds ruling #91 R4 (lope preinstalled on PAX: no assumption of `$EDITOR`, fzf, XDG or a `HOME` other than `/`) | R4 folded in |
| gump | `43c114d` (0.2.7) | cloned from `https://github.com/tenseleyFlow/gump`, `43c114d071754a1d…` "bump to 0.2.7"; 1,919 lines of Rust; built on kasumi `cargo build --release --locked` in 15 s | none |
| wolf 0.2.33 | `v0.2.33` at `85dab5d7` | tag object `56110e4f…` → `85dab5d7e597…`, read twice; release 417610226; `wolf 0.2.33 (wolfgang, pin 85dab5d)` | none |
| lupin 0.1.54 | `v0.1.54` at `0e536e8` | tag object `9c98d445…` → `0e536e8fb451…`; release 415937354; `lupin 0.1.54 (wolf-interp, reference interpreter at pin 294d626)` | none |
| the digests | by digest, each read twice | release API read twice, equal both times; linux x86-64 pair hashed twice after download on kasumi: wolf `4f955e8d…`, lupin `175df238…` | none |
| wolf-std | `cceda63` | `cceda63151430eac…`; the 0.2.33 archive's `std/STD-REV` names the same commit | none |
| pelt | `cc2fdc9` | `cc2fdc9e0f39…` (sh18's notes); `src/sh/exec.lu:2253–2297`: a name not found prints `NAME: not found`, status 127, and no hook runs | — |
| kasumi | `/home` ~26 GB | 22 GB free at the start; bash 5.3.20, zsh 5.9.2, fish 4.9.3, fortsh, fzf, python3, podman, hyperfine present; **zoxide absent** (not installed, per the rules) | 4 GB less |

## 3. Prediction (before the first change)

1. **The matcher.** gump's ranking is fully observable from outside
   (`gump query -a -s` prints the combined score), so a Smith-Waterman
   score whose constants are fitted to probes of the binary will land
   where gump lands on at least 97% of the corpus. The residue will be
   **ties**: gump keeps its store in a `HashMap` (`store.rs:37`) and
   sorts with a stable sort (`query.rs:30`, `fuzzy.rs` `rank`), so equal
   combined scores come back in a per-process random order; lope breaks
   them deterministically and agrees with gump only as "one of the tied".
2. **The store.** gump's `db.bin` is bincode 1 (u32 version, u64 count,
   per entry a u64-prefixed path, an f64 score, a u64-prefixed RFC 3339
   time and a u64 count, then the last-cleanup time); a reader of that
   layout imports gump's database with every score and time exact.
   wolf 0.2.33 has **no `fsync`** builtin, so lope's atomic write is
   temp-then-rename without the sync gump does (`store.rs:129`): a
   named gap, a wolf-lang issue to file.
3. **The hooks.** bash runs `command_not_found_handle` in a separate
   execution environment, so gump's bash no-prefix jump changes the
   directory of a subshell and **not** the shell's: measured on a PTY it
   will print nothing and stay put. lope's bash hook rewrites the line
   at Enter (`bind -x`), as gump's zsh (`zle` widget, `init.rs:204`) and
   fish (`bind \r`, `init.rs:373`) hooks already do. gump's `gi` needs
   fzf (`init.rs:88`) and has no fallback.
4. **pelt `cc2fdc9`** has no command-not-found hook: lope's pelt hook
   records `cd` by a function named `cd` (a function is found before a
   regular built-in) and `g`/`gi` work; the no-prefix jump waits on a
   pelt hook whose shape the report states.
5. **Speed.** At 10,000 entries the query path is dominated by reading
   the store and the per-path scoring; with a subsequence prefilter
   before the dynamic programme lope's `query` will be within 1.5× of
   gump's on kasumi under `taskset -c 0-3`, and the gate (lope no slower
   than gump) will need the prefilter to pass.
6. **The static build** links with `cc -static` in an Ubuntu container
   (pax `tools/mkpelt`'s shape): ET_EXEC, no PT_INTERP.
7. **linux aarch64** builds no tier at 0.2.33 (wolf-lang#614, as pelt's
   CI asserts), so that host asserts both refusals by name.
