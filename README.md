# lope

(noun) a wolf's travelling gait: ground-covering, fast without hurry.

## A smarter cd

A directory jumper using frecency, written in [wolf](https://github.com/wolffe-lang/wolf-lang).
Type directory fragments, land where you meant.

```
projects           # jumps to ~/code/projects
gmp                # jumps to ~/code/gump (fuzzy)
doc my             # jumps to ~/documents/myfiles (multi-term)
```

No command prefix required.

lope is [gump](https://github.com/tenseleyFlow/gump) 0.2.7 ported to wolf and
renamed (Track 13, ruling #91): the same store rule, frecency, hooks,
resolution order and commands; a matcher of its own (gump's wraps a third
party's, nucleo); and two things gump could not have: a hook for
[pelt](https://github.com/wolffe-lang/pelt), the POSIX shell in wolf, so lope
runs on PAX; and its speed measured against gump's in CI.

## Install

lope is not published yet. The packaging is prepared in `packaging/`
(a Homebrew formula, an AUR `PKGBUILD`, an RPM spec) for a release.

**From source** (the toolchain is fetched by digest; wolf 0.2.35):
```bash
tools/fetch-toolchain
tools/build --release
cp target/release/lope ~/.local/bin/
```

**Static** (x86-64 Linux, the build PAX runs):
```bash
tools/mkstatic target/static      # on a baseline glibc, e.g. an Ubuntu container
```

## On PAX

lope is preinstalled on [PAX](https://github.com/wolffe-lang/pax) as
`/bin/lope` (px54): pax's `tools/mklope` builds it from this tree at the
commit `user/lope.pin` names, with the toolchain this tree pins, as
`tools/mkstatic` does (`cc -static`, a baseline glibc, the digest in the
pin). PAX's console shell is pelt, started with `ENV=/etc/shrc`, and
`/etc/shrc` runs `eval "$(lope init pelt)"`: a `cd` is recorded, `g` and
`gi` jump, and a word that names no command jumps (pelt's
`command_not_found_handle`). On pelt `2dc8dbe` or later, it also enables
`autocd`, so a slashed directory word such as `home/pax` or `/home/pax/`
changes directory before the hook could see it. The store is the user's,
`$HOME/.local/share/lope/store` (`/.local/share/lope/store` for root,
whose `HOME` is `/`), in PAX's in-memory tree until PAX has storage. PAX
has no fzf, so `gi` shows its numbered menu; with no editor, `lope edit`
says so and changes nothing.

## Shell Setup

Add to the shell's startup file:

**Bash** (`~/.bashrc`)
```bash
eval "$(lope init bash)"
```

**Zsh** (`~/.zshrc`)
```zsh
eval "$(lope init zsh)"
```

**Fish** (`~/.config/fish/config.fish`)
```fish
lope init fish | source
```

**fortsh** (`~/.fortshrc`)
```sh
eval "$(lope init fortsh)"
```

**pelt** (the file `$ENV` names)
```sh
eval "$(lope init pelt)"
```

Restart the shell or source the file.

## Usage

Just type where you want to go:

```bash
projects           # jumps to ~/code/projects
doc                # jumps to ./Documents (fuzzy CWD match)
gmp                # jumps to ~/code/gump (fuzzy database match)
conf fish          # jumps to ~/.config/fish (multi-term)
```

Or use the `g` command:

```bash
g foo              # jump to best match for "foo"
g                  # go home
g -                # go back
gi foo             # pick from the matches: fzf, or a numbered menu without it
```

Resolution order:
1. Existing commands/aliases/builtins
2. Exact directory in CWD
3. Fuzzy match against CWD contents
4. Fuzzy match against database

Directories are learned automatically as you `cd` around.

### The hooks, shell by shell

Each was exercised in real sessions on pseudo-terminals (`tools/hook-sessions`,
`tests/hooks/expected.tsv`): a `cd` is recorded, an unknown word jumps, a real
command is never shadowed, `g`, `g -`, `g` alone and `gi` (with fzf and without).

| shell | records a `cd` by | the no-prefix jump | measured |
|---|---|---|---|
| bash 4+ | `PROMPT_COMMAND` | Enter reads the line first (`bind -x`) and rewrites an unknown word to `cd -- DIR` | bash 5.3 |
| zsh | `chpwd_functions` (or `precmd`) | a `zle` widget on `accept-line` (gump's) | zsh 5.9 |
| fish | `--on-variable PWD` (or `fish_prompt`) | an Enter binding (gump's) | fish 4.9 |
| fortsh | a `DEBUG` trap | `command_not_found_handle` (gump's; fortsh runs it in the shell itself) | fortsh 1.10 |
| pelt | `cd` as a function (or `PS1`) | `command_not_found_handle`, which pelt calls in the shell itself since sh21 (pelt#43) | pelt `3b0bab9` (`pelt.pin`) |

Where lope's hooks part from gump's, on purpose:

- **bash's jump.** bash runs `command_not_found_handle` in a subshell, so a
  `cd` there never reaches the shell: gump's bash hook prints nothing and stays
  put (measured: `tests/hooks/gump-record.tsv`). lope reads the line at Enter
  instead, as gump's zsh and fish hooks already do. bash 3.2 (macOS's own) has
  no `READLINE_LINE`, so there the jump is left out; `g` and `gi` work.
- **`gi` without fzf.** gump's `gi` needs fzf. lope's falls back to a numbered
  menu of the best nine, chosen by one digit (PAX has no fzf).
- **Enter inside `read`, in fish.** gump's fish hook binds Enter for the whole
  shell, so the answer to any `read` that looks like a directory fragment is
  rewritten to a `cd` (measured: `gi`'s menu answer `1` became a jump to a
  path holding a 1). lope's leaves a `read`'s answer alone.
- **One visit per jump in bash and fortsh.** gump's `g` records the visit and
  the prompt's directory check records it again; lope's records it once.

## Commands

```
lope add <path>       # manually add directory
lope remove <path>    # remove from database
lope list             # show all entries
lope list --score     # show entries with scores
lope query <terms>    # print best match (for scripts)
lope clean            # remove non-existent directories
lope import           # import from gump/zoxide/autojump/z/fasd
lope edit             # edit database as text
```

Every message and exit status is gump's, held to a recording of the gump
binary (`tools/cli-check`, 95 command lines): help and version on standard
output with 0, a usage error on standard error with 2, `lope: …` with 1.

## Options

```bash
lope init bash --cmd j       # use 'j' instead of 'g'
lope init bash --hook prompt # track on every prompt (the default, pwd: on directory change)
lope init bash --no-cmd      # skip g/gi aliases, keep no-prefix jumping
```

## Environment

| Variable | Default | Description |
|----------|---------|-------------|
| `LOPE_DATA_DIR` | `$XDG_DATA_HOME/lope`, else `$HOME/.local/share/lope` | Store location, on every host (macOS too); `/` stands in for an unset `HOME` |
| `LOPE_MAXAGE` | `10000` | Max total score before aging |
| `LOPE_EXCLUDE` | - | Colon-separated paths to ignore |
| `EDITOR`, `VISUAL` | `vi` | `lope edit`'s editor (arguments allowed); none found is a clean refusal |

## How it works

1. Shell hook records directories on `cd`
2. Frecency score = access count × recency multiplier (×4 within the hour,
   ×2 within the day, ×½ within the week, ×¼ after)
3. Query matches terms against paths using fuzzy matching (`docs/MATCHER.md`)
4. Unknown commands are intercepted and checked against the database

The store is text, one directory per line, versioned, and written atomically
and durably: a temporary file, synced, renamed over the store, and the
directory synced (`docs/STORE.md`, which states the cost: two syncs per save). `lope import` moves a gump user over in one step: gump's
`db.bin` is read with every score, visit count and time kept.

## The matcher, and gump as its oracle

lope's matcher is its own, written from first principles: a Smith-Waterman
alignment with word-boundary, camel-case and run bonuses and an affine gap
penalty floored at zero (`docs/MATCHER.md` gives the recurrence). No source of
nucleo, fzf, skim, zoxide, autojump, z or fasd was read. Its constants were
fixed by asking the gump binary (`gump query -a -s` prints the score), and the
binary is the oracle it is held to:

- **322 probe rows** (`tests/oracle/probes.jsonl`), each a score gump printed:
  322 of 322 equal.
- **654 recorded cases** over five synthetic stores of 50 to 5,000 paths and a
  working directory of 40 (`tests/oracle/`): one term and several, whole
  names, prefixes, fragments, abbreviations, typos, upper case, slashes, words
  in and out of order. **654 of 654 agree** (floor 100%): 490 of 490 where
  gump's best is one path, and 164 where gump's best score is shared, where
  gump's answer is its hash map's order and changes from run to run; lope
  breaks those ties by frecency, then the shorter path.
- **Folding** (`tests/oracle/fold.jsonl`): which ASCII letter a Latin letter
  with diacritics answers to. lope's table comes from Unicode names; 508 of 896
  code points agree with gump's (floor 56.69%). The rest are lope folding
  capitals and letters gump leaves alone, gump folding a few that are not
  diacritic forms (ß, ı, ſ), and the Latin Extended Additional block, where
  gump answers different letters (ḁ as c).

## Speed

Measured cold (a fresh process per run, as a hook starts one), with a
10,000-entry store, median of 31 runs, under `taskset -c 0-3`
(`tools/speed`); CI gates the query path on every run: lope no slower than
gump.

On kasumi (16 cores, idle: load 0.1), 2026-10-20, the release tier, lope's
and gump's runs interleaved (`notes/lp00-evidence/speed-kasumi-interleaved.json`):

| command | lope | gump | lope / gump |
|---|---|---|---|
| `query` (the median of eight queries' medians) | 11.49 ms | 14.77 ms | **0.78** |
| `init bash` | 2.93 ms | 3.21 ms | 0.91 |
| `list` (10,000 lines) | 4.54 ms | 17.10 ms | 0.27 |

lope is faster on seven of the eight queries; on `wolf`, which every path of
the store holds (they live under `/home/wolf`), the two are even (15.2 ms to
14.9, 1.02). Absolute times move with the host (an idle kasumi clocks down;
loaded, the same query mix ran in 4.7 ms against 7.0, 0.68); the ratio is the
measurement, and CI's runner gave 0.70. gump's `list` is slow because its sort
reads the clock inside every comparison (`list.rs:11`, `entry.rs:51`).

zoxide is not installed on kasumi, so gump against zoxide was not measured.

## Licence

GPL-3.0-or-later (`LICENSE`), with the wolf Training Data Permission
(`LICENSE-TRAINING-DATA`). gump is MIT and every commit of it is the
maintainer's, so the port is theirs to relicense.
