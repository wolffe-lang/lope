# lp02 — `lope init pelt` and `autocd`

Contract: `sprints/lope/lp02-init-pelt-autocd.md` in the planning repository
(`wolf`, planning trunk `d52b01b`); `sprints/RULES.md` §§5–7 and the lope
track's rules 0–6. This record's first three sections are committed before a
source, test, pin, or generated-file change; evidence and completion are
filled in as the lane lands.

## 1. Forbidden

As the contract, `RULES.md`, and the track. gump is the maintainer's and its
packages remain untouched; no source of any shell, matcher, editor, or listed
third-party directory jumper is read. pelt is an org program, run as a black
box; its README, changelog, and sh23 evidence state the option's public
behaviour. No dependency but wolf-std, and the wolf 0.2.34 (`9da7bdcf`), lupin
0.1.55 (`e642f26`), and bundled std `e036bec` pins do not move. Builds and
sessions run on kasumi; the static pelt build is made in a container, not with
kasumi's host glibc. Sessions own their PTYs and scratch HOME/XDG trees. No
merge, tag, release, issue filing, or issue closure; no attribution trailers.
Every new expectation row is red before it is green. Commands run with
`taskset -c 0-3`, and jobs record their own pid if detached. The pelt binaries
for both pins were built from their own trees in kasumi's
`localhost/px13-ubuntu` container; no shipping or session pelt came from the
kasumi host glibc.

## 2. Inputs, verified

| input | contract says | verified before change |
|---|---|---|
| lope trunk | `7f2ab05` | branch `lp02` cut at `7f2ab05` |
| emitter | `src/cmd/init.lu`, `shell/pelt/*.sh` | pelt concatenates `hook`, selected trigger, commands, menu, then `jump`; no option line yet |
| old pelt pin | `3b0bab9` | `pelt.pin` is `3b0bab9881f5d099cd5258a6f50a9f2d55d91bc4` |
| new pelt | `2dc8dbe` | `2dc8dbec5fb90f9b0525e4531782b34b9e54eae2`; its README and Unreleased changelog document `set -o autocd` |
| public option rule | interactive only | slashed and bare directory names run as `cd -- NAME`; a real command wins and a non-directory still reaches `command_not_found_handle` |
| hook oracle | `tests/hooks/expected.tsv` | current pelt has ten ordinary hook rows; `tools/hook-sessions` supplies the isolated PTY, HOME, XDG and pelt `ENV` |
| PAX setup | `/etc/shrc` | README says pelt starts with `ENV=/etc/shrc`, which evaluates `lope init pelt` |
| tier mapping | `ci/tiers.py` | `src/**`, `shell/**`, `tests/**`, `pelt.pin`, and `tools/**` are `pr`; prose is `README.md`, `CHANGELOG.md`, and `notes/**` |

The changed paths therefore form one repository program and its test/pin,
not CI, runtime, loader or specification: recommendation is
`Footprint: module`.

## 3. Prediction (before the first change)

1. At `3b0bab9`, `set -o autocd` prints `set: -o autocd: no such option` on
   standard error and returns 2. Unguarded in the emitted init, it prevents a
   clean `eval`; the emitted line must instead be `set -o autocd 2>/dev/null
   || :`, never a version test.
2. At `2dc8dbe`, that unguarded command is silent and returns 0. Once lope
   emits the guarded form and pins this pelt, `home/pax`, `/home/pax/`, `..`,
   and a child directory name all change directory in an interactive session;
   the first two are the slashed forms the old hook could not see.
3. The bare `proj` case still reaches lope's `command_not_found_handle`; a
   real command whose name is a directory runs rather than changing directory;
   a missing word remains 127. Bash and zsh output stay unchanged: lope does
   not emit `shopt -s autocd` or `setopt autocd` for them.
4. The complete five-shell census changes only pelt's new option rows; all
   existing bash, zsh, fish, fortsh, and pelt rows retain their answers.

## 4. Prediction scored and evidence index

### 4.1 The option and its guard

Both pins were checked as black boxes, with release binaries built in the
`localhost/px13-ubuntu` container. At `3b0bab9`, an unguarded `set -o autocd`
printed `pelt: pelt: line 1: set: autocd: no such option` on standard error
and the process exited 2. Its unguarded `eval` also exited 2. At `2dc8dbe`,
the line and its `eval` were silent and exited 0.

Prediction 1 therefore scored **partly wrong**: the old wording has pelt's
prefix, and the proposed bare `set -o autocd 2>/dev/null || :` still exits a
non-interactive old pelt with 2 because `set` is a fatal special builtin. The
implemented guard probes in a subshell, then changes the parent only on
success:

```sh
if (set -o autocd) 2>/dev/null; then
    set -o autocd
fi
```

The old pelt's interactive init survives this probe and retains every old hook
answer. At the new pin the parent option is on. Predictions 2 and 3 held:
`home/pax` and an absolute slashed counterpart land in `/home/pax`, `..` lands
in `/t/beta`, `alpha` lands in `/t/alpha`, bare `proj` remains lope's fuzzy
jump to `/t/projects/myapp`, `printf` and `ls` run in `/t`, and the unknown
word returns 127. The bash and zsh emitted texts were not changed.

### 4.2 Red then green rows

Against the old container-built pelt, the two slashed rows were red (`/` rather
than `/home/pax`) while all existing hook rows and the old-pelt guard stayed
alive. Against `2dc8dbe`, the final report was 0 rows different. To prove the
other five newly added pelt expectations individually detect a failure, a
local expected-data plant replaced every `autocd-*` answer with `PLANTED`:
the harness was red with all seven new rows different, status 1; restoring the
tracked expectations made it green.

| row | pelt answer at `2dc8dbe` |
|---|---|
| `autocd-rel` | `/home/pax` |
| `autocd-abs` | `/home/pax` |
| `autocd-parent` | `/t/beta` |
| `autocd-child` | `/t/alpha` |
| `autocd-proj` | `/t/projects/myapp` |
| `autocd-real` | `ran /t` |
| `autocd-miss` | `status 127, said not found` |

### 4.3 Five-shell census and module gauntlet

Kasumi, `taskset -c 0-3`, final source head `1d4d354` before this prose
record: `tools/hook-sessions` used its own PTYs and HOME/XDG roots, the
container-built `2dc8dbe` pelt, and `tests/hooks/expected.tsv`.

| shell | expected rows | differences |
|---|---:|---:|
| bash | 10 | 0 |
| zsh | 10 | 0 |
| fish | 10 | 0 |
| fortsh | 10 | 0 |
| pelt | 17 | 0 |
| total | 57 | 0 |

No answer outside pelt moved, as predicted. The complete kasumi gauntlet was
green: format and both generators, native and release builds, two wolf tests,
two lupin runs, both tiers' 322/322 probes, 654/654 oracle corpus, 508/896
fold floor, 95/95 CLI rows, import, edit, and sync census; gump fetch; this
census; speed (query 17.85 ms / 29.17 ms, ratio 0.612); and selftest's seven
planted-red harnesses. Its final log is
`~/lanes/lp02/scratch/green/kasumi-gauntlet-final.log`; the final report is
`~/lanes/lp02/scratch/green/hooks-kasumi.tsv`.

## 5. Done-when

- Guarded pelt init, its regenerated emitter, and pelt `2dc8dbe` pin:
  `7c13657`, `f558430`, `1d4d354`.
- Seven pelt option rows, seen red before green: `329f9d1`; the rows and
  census are in §4.2–§4.3.
- README and Unreleased changelog: `bf4cd2d`.
- Prediction, inputs, final measurement, PR and audit record: this note.

## 6. Issues

- To file: none found.
- To close: none. pelt#49 was already closed; this lane does not file or
  close issues.
