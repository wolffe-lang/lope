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

## 4. Evidence index

Every number below was measured; where it was measured is named.

### 4.1 The matcher, against the oracle

- **Probes** (`tests/oracle/probes.jsonl`, `tools/probe-check`): 322 rows,
  each a score the gump binary printed for a one-path store at frecency 0
  (recorded on kasumi with the gump binary built at `43c114d`). lope:
  **322 of 322 equal**, both tiers, on kasumi and in CI. Which rows fixed
  which constant: `docs/MATCHER.md`, "Classes and bonuses".
- **The corpus** (`tests/oracle/corpus.jsonl`, `tools/oracle-check`): 654
  cases (605 over five stores of 50, 283, 869, 2,500 and 5,000 paths; 49 in
  a working directory of 40 names), gump asked three times per case plus its
  full ranking. lope: **654 of 654** (490 of 490 with one best answer; 164
  inside gump's tie set). The floor (`tests/oracle/FLOOR`) is 100%.
- **Folding** (`tests/oracle/fold.jsonl`, `tools/fold-check`): 896 code
  points; **508 agree** (56.70%; floor 0.5669). By class: 236 Latin
  capitals and 69 Latin small letters lope folds and gump does not; 69
  Latin Extended Additional letters both fold, to different letters (gump's
  are not the base letter: `ḁ`→c, `ḃ`→e, `ḍ`→i); 14 gump folds and lope
  does not (`ß`, `ı`, `ſ`, turned and open letters).

### 4.2 The command line

`tests/cli/expected.jsonl`: 95 command lines recorded from gump
(`tools/cli-record`); `tools/cli-check`: **95 of 95** (one, `init zsh
--cmd=j`, by status only: its text carries lope's `gi` menu).

### 4.3 The hooks, on PTYs

`tools/hook-sessions` on kasumi (bash 5.3.20, zsh 5.9.2, fish 4.9.3,
fortsh 1.10.0, pelt `cc2fdc9` built from its tree at its own pin): lope's
rows are `tests/hooks/expected.tsv`, gump's `tests/hooks/gump-record.tsv`.

| step | lope bash | lope zsh | lope fish | lope fortsh | lope pelt | gump bash | gump zsh/fish/fortsh |
|---|---|---|---|---|---|---|---|
| a `cd` recorded | 3 of 3 | 3 of 3 | 3 of 3 | 3 of 3 | 3 of 3 | 3 of 3 | 3 of 3 |
| an unknown word jumps | yes | yes | yes | yes | **no** (no hook in pelt) | **no** (stays put) | yes |
| two words | yes | yes | yes | yes | no | no | yes |
| a directory of the cwd | yes | yes | yes | yes | no | no | yes |
| a fragment of one | yes | yes | yes | yes | no | no | yes |
| a real command runs | yes | yes | yes | yes | yes | yes | yes |
| no match: the shell's not-found, 127 | yes | yes | yes | yes | yes | yes | yes |
| `g`, `g -`, `g` alone | yes | yes | yes | yes | yes | yes | yes |
| `gi` without fzf | menu | menu | menu | menu | menu | **nothing** | **nothing** |
| `gi` with fzf | yes | yes | yes | yes | yes | yes | yes |

In CI (ubuntu-latest: bash 5.2.21, zsh 5.9, fish 3.7.0) the bash, zsh and
fish rows hold.

### 4.4 Import and edit

`tools/import-check` (fixtures written from the formats as gump's importer
states them, `tests/import/FORMATS.md`): lope's summary and resulting
listing equal `tests/import/expected.txt`; gump's own import of the same
autojump, z, fasd and zoxide files gives the same entries at the same
frecency (kasumi, `--gump`). `tools/edit-check`: an edit written back with
times and counts kept, and the three refusals (an editor that fails, one
that is not there, none at all).

### 4.5 Speed

`tools/speed`, 10,000 entries, cold, median of 31, `taskset -c 0-3`. kasumi
(load 8 to 9): query 9.27 ms against 13.03 (**0.711**), init 0.95 against
1.08 (0.881), list 8.50 against 24.48 (0.347). CI: see §4.7. zoxide is not
on kasumi: gump against zoxide not measured.

### 4.6 The static build

`tools/mkstatic` in `localhost/px13-ubuntu` (Ubuntu 24.04.5, glibc 2.39,
gcc 13.3.0) on kasumi, twice, the same bytes: `lope
1a834fe58ec5734444e3a24e07298abdca127151acfea4f538ca952528939e71 14425328`,
ET_EXEC, no PT_INTERP; the oracle (654 of 654) and the probes (322 of 322)
hold on it. CI's runner builds its own (§4.7); the two differ by the
image's `libc.a`.

### 4.7 CI runs

RUNS-TO-COME

## 5. Done-when

DONE-WHEN-TO-COME
