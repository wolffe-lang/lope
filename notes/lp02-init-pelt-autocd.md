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
`taskset -c 0-3`, and jobs record their own pid if detached.

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

## 4. Evidence index

Pending the two black-box pelt probes, planted expectation rows, and final
five-shell census on kasumi.

## 5. Done-when

Pending the guarded emitter, pelt pin, red-then-green rows, README and
changelog wording, census, module gauntlet, PR, and audit.
