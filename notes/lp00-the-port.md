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
| planning trunk | `434ebd8` | `434ebd8` (lp00 contract); `700c3e0` adds ruling #91 R4 (lope preinstalled on PAX: no assumption of `$EDITOR`, fzf, XDG or a `HOME` other than `/`); `be2eebb` adds ruling #92 (`sprints/RULES.md`: CI tiered in wolf-lang's shape; hand back once the final head's PR tier is green and its full tier is running) | R4 and #92 folded in |
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
at `ee83f5d` (load about 8; `lp00-evidence/speed-kasumi-ee83f5d.json`):
query 4.71 ms against 6.96 (**0.677**), init 0.48 against 0.55 (0.870),
list 5.03 against 16.28 (0.309); per query lope is faster on seven of
eight and even on `wolf` (8.92 against 8.87, 1.005). Before the hay and
the rows were reused (`d0d76d9`) and the class tables (`ee83f5d`), the
first measurement was 14.78 against 17.66 (0.837). CI at `ee83f5d` (run
39327219714): 6.64 against 9.52 (0.698), init 0.892, list 0.293. zoxide
is not on kasumi: gump against zoxide not measured.

### 4.6 The static build

`tools/mkstatic` in `localhost/px13-ubuntu` (Ubuntu 24.04.5, libc6-dev
2.39-0ubuntu8.9, gcc 13.3.0) on kasumi, from `src/` at `ee83f5d`, twice, the
same bytes: **`lope 1faed82b10c2728d090165fe99ccce97fe1506882014d71f465bffe8a1277409
14426088`**, ET_EXEC, no PT_INTERP; the oracle (654 of 654) holds on it.
CI's runner builds its own from the same tree (run 39327219714: `lope
08741bfa3e73cfd606286c8fca3ae11bc3b24f09593b876d00b2afc90381514d
14189464`); the two differ by the image's `libc.a`, so a PAX pin names the
image with the digest.

### 4.7 CI runs

| run | head | what | result |
|---|---|---|---|
| 39323282558 | `6382943` | first PR run | linux red on zsh only (Ubuntu's global zshrc stops at compinit's question): `c8d9d15` starts zsh with `-d` |
| 39324416507 | `7fd318f` | PR run | linux red on bash's `miss` only (Ubuntu's `/etc/bash.bashrc` handler): `ee83f5d` reads only the session's rcfile |
| **39327219714** | `ee83f5d` | PR run, `tier pr` | **green**: every gate on linux x86-64 |
| 39324524143 | `d75a85b` (`lp00-plant-a`, PR #2 then) | PLANT A, `tier pr` | red as planted: wolf test, lupin, probe-check, oracle-check, cli-check, import-check, edit-check, hook-sessions, speed, mkstatic. Two plants did not bite, both the plant's fault: the fold plant removed the capitals' arm, which `lower` never reaches (re-planted in B); the selftest plant was masked by the matcher plant (re-planted in B) |
| 39327414935 | `3d786a6` (PR #2, `full-matrix`) | PLANT B, `tier full` | red as planted: the planner's test, wolf fmt, gen-hooks, fold-check, cli-check and selftest on linux; cli-check on macOS; the aarch64 refusal check; `tier full`. Collateral, as expected: probe-check (its Unicode rows read the fold plant); macOS's hook step red only on its fzf row, asked with no fzf there: `tools/hook-sessions` now says so and skips it |
| (PR #1's body) | the final head | PR run, `tier pr`, then `full-matrix`, `tier full` | named in PR #1's body: a commit cannot carry its own run's id |

## 5. Done-when

- The repo exists, private: `wolffe-lang/lope`, trunk seeded at `ce00c73`
  (licences, a README line); this lane's work on `lp00`, PR #1.
- CI on three hosts, tiered from the start (ruling #92): `tier pr` green at
  the final head; `tier full` running there at hand-back.
- The oracle recorded and the agreement stated: 654 of 654 (floor 100%),
  322 of 322 probes; folding 508 of 896; every disagreement listed (§7), a
  ruling asked.
- The hooks seen working in bash, zsh, fish and fortsh, and in pelt as far
  as pelt allows (§4.3, §6).
- The import fixtures green; edit and its refusals green.
- The speed ratios in the README, gated in CI (query no slower than gump).
- Every gate seen red in CI (§4.7: PLANT A and PLANT B).
- Packaging prepared, not published; the static digest (§4.6).
- `wolf/tools/lane-audit.sh lope lp00 1`: the status in the report.

## 6. The pelt finding: the hook lope needs (for sh21)

**Measured** (pelt `cc2fdc9`, built from its tree at its own pin on kasumi;
`src/sh/exec.lu:2253–2297`): a simple command whose name is not found
prints `pelt: line N: NAME: not found` and the status is 127; no function
is called. lope's pelt hook therefore records directories (`cd` is a
function: pwd mode; or `PS1` runs the hook: prompt mode) and `g`, `g -`,
`g` alone and `gi` (menu and fzf) all work, measured on a PTY; the
no-prefix jump does not.

**The shape lope needs, which `lope init pelt` already assumes:**

1. **The name.** A function named `command_not_found_handle` (bash's name,
   which fortsh also uses, so one text serves the shells that have it).
2. **When.** When the shell is interactive, and a simple command's name
   has no `/` and command search (XCU 2.9.1.4) finds no special built-in,
   function, regular built-in or file on `PATH`; never inside the handler
   itself (a name not found there is the plain 127).
3. **Where it runs.** In the **current shell environment**, as a function
   call, not a subshell: a `cd` in it changes the shell's directory (bash
   runs its handler in a subshell, which is why gump's bash hook cannot
   jump; fortsh runs it in the shell, which is why gump's fortsh hook can).
4. **With what.** `$1` the command's name, `$2`… its arguments, after
   expansion, as the command would have had them; the command's
   redirections apply around the call as around any function call.
5. **What it answers.** Its return status is the command's status. **When it
   returns 127, pelt says what it always says** (`NAME: not found`)
   itself, so the handler need not imitate the message.
6. **How `cd` is observed.** Nothing new: `cd` changes `PWD` and `OLDPWD`
   as now; lope's pwd hook wraps `cd` in a function (`command cd` reaches
   the built-in). A `chpwd`-style hook would let lope stop wrapping `cd`,
   but is not needed.

On PAX (pelt as pid 1, `sh -i -m`, serial and PS/2 input, the 160×50 grid)
nothing in this depends on the line editor: the call happens in command
execution, after Enter. `gi`'s menu is at most nine lines and a prompt.
The store lives under `$HOME/.local/share/lope` (`/` when `HOME` is
unset: `/.local/share/lope`) in PAX's in-memory tree; no `$EDITOR`, no fzf
and no XDG variable is assumed (ruling #91 R4), each with its default
stated in README.md.

## 7. Disagreements with gump, and the ruling asked

Each is lope's on purpose; the recommendation for each is to keep lope's.

| # | where | gump | lope | recommend |
|---|---|---|---|---|
| D1 | ties at the best score (164 of 654 corpus cases) | its hash map's order, a different answer each run | the uncapped frecency, then the shorter path, then byte order: always one of gump's possible answers, always the same | keep ours |
| D2 | folding (388 of 896 code points) | Latin-1 capitals and small letters fold; Ext-A/B capitals do not; ß, ı, ſ and turned letters fold; Latin Extended Additional folds to wrong letters (ḁ→c) | every Latin letter WITH a diacritic, small or capital, to its base letter, from Unicode names | keep ours |
| D3 | bash's no-prefix jump | stays put (its handler runs in a subshell) | Enter rewrites the line (`bind -x`, bash 4+) | keep ours |
| D4 | `gi` without fzf | nothing happens | a numbered menu (PAX's only path) | keep ours |
| D5 | a `g` jump in bash and fortsh | recorded twice (`g`'s hook and the prompt's check) | once | keep ours |
| D5b | Enter inside `read`, in fish | the Enter binding rewrites a `read`'s answer that matches a directory into `cd "DIR"` (measured: `gi`'s menu answer `1`, with a store holding `…/v1`) | a `read` keeps its answer (the guard in `shell/fish/jump.sh`; the unguarded text red on exactly the menu row, kasumi) | keep ours |
| D6 | an empty item in the exclude list (`GUMP_EXCLUDE=`, `a::b`) | excludes every path | excludes nothing | keep ours |
| D7 | `edit` | JSON; every time reset to now, missing paths dropped; `$EDITOR` one program name | text; times and counts kept; `$EDITOR` split at spaces | keep ours |
| D8 | the store on macOS | `~/Library/Application Support/gump` | `$XDG_DATA_HOME/lope` on every host (R4's stated default); `import` still finds gump's macOS file | keep ours |
| D9 | the atomic write | temp, fsync, rename | temp, rename: wolf 0.2.33 has no fsync | move when wolf has it |
| D10 | `init`'s shells | bash, zsh, fish, fortsh | the same and pelt | keep ours |
| D11 | `import` | zoxide, autojump, z, fasd | the same and gump's `db.bin`, kept whole | keep ours |

The contract names `--no-aliases`; gump's flag is `--no-cmd` (`cli.rs:71`):
lope takes gump's and accepts `--no-aliases` as the same flag, unlisted.

## 8. Issues to file (none filed by the lane)

- **pelt**: a command-not-found hook, the shape in §6 (sh21's).
- **wolf-lang**: no `fsync`/`fdatasync` builtin: a store cannot be written
  durably (temp, sync, rename); lope's `src/db/store.lu` names it.
- **fortsh** (FortranGoingOnForty/fortsh, the maintainer's): fortsh 1.10.0
  stops a script silently at an empty case arm (`[1-9]) ;;`): nothing after
  it runs, status 0 (measured on kasumi; lope's menu writes `: ;;`).
- **gump** (tenseleyFlow/gump, the maintainer's, for the record; lope
  replaces it): D3, D4, D5, D5b, D6 above; `list` sorts with the clock read in
  every comparison (`list.rs:11`, `entry.rs:51`: 24.5 ms against lope's
  8.5 at 10,000 entries); `import --help` says "from zoxide" for four
  tools; frecency's weight capped at 40 makes every often-visited
  directory tie (D1).
- **pax**: the lope pin (px54, queued by R4), with this static build.
