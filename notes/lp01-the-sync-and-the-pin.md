# lp01 — the store's sync and the pin

Contract: `sprints/lope/lp01-the-sync-and-the-pin.md` in the planning repo
(`wolf`, trunk `16a2560`, the contract at `4e48bee`); `sprints/RULES.md`
and the track's rules 0–6 (`sprints/lope/index.md`). This file is the
lane's record. §1 to §3 are committed before the first change under
`src/`, `tools/`, `tests/`, `packaging/` or the pin; §4 (the evidence) and
§5 (done-when) are filled in as the work lands.

## 1. Forbidden

As the contract, RULES.md and the track's rules. gump (the maintainer's)
read and cited by `file:line` at `43c114d`, its packages untouched; no
source of nucleo, fzf, skim, zoxide, autojump, z or fasd; pelt (wolffe-lang,
the org's) read at `3b0bab9` for its hook's shape and run as a black box.
No dependency but wolf-std; the std wrappers for the syncs are sc69's and
not in `e036bec`, so the store calls the builtins. Toolchains from release
archives by digest, each read twice. Builds, tests, the strace census and
the static build on kasumi (the static build in `localhost/px13-ubuntu`,
never kasumi's CachyOS glibc); nothing built on nomad-1. Hook sessions only
on PTYs the tool starts, with scratch `HOME` and `XDG_*`. Every new row seen
red before green, planted in CI. No merge, no tag, no issue filed or closed
(listed in the report), nothing published. No attribution trailers. Jobs on
kasumi `setsid -f` with their pid recorded; kill by recorded pid only.

## 2. Inputs, verified (2026-10-21)

| input | contract says | measured | drift |
|---|---|---|---|
| lope trunk | `5ac37df` | `5ac37df` (lp00's merge); the branch `lp01` cut there | none |
| wolf 0.2.34 | `v0.2.34` at `9da7bdcf`, release 419552903 | tag object `38ab81cb…` → commit `9da7bdcf2aea…`, read twice; release 419552903; `wolf --version`: `wolf 0.2.34 (wolfgang, pin 9da7bdc)` / `paired with lupin 0.1.55 (reference interpreter), pin 294d626` | none |
| wolf archives | x86-64 `88a9dd3d…`, aarch64 `ca5cadf9…`, macOS `29c8331f…`, windows `77bb8403…` | release API read twice, equal: `88a9dd3da1c9…` (80,433,878 B), `ca5cadf936dc…` (76,212,750 B), `29c8331f5d18…` (18,925,363 B), `77bb8403aeea…` (15,911,654 B); the three unix archives downloaded on kasumi and hashed twice, equal to the API | none |
| lupin 0.1.55 | `v0.1.55` at `e642f26`, linux x86-64 `1152abc0…` | tag object `047184fb…` → commit `e642f2630ad4…`, read twice; release 418932753; linux x86-64 `1152abc0bef6…`, aarch64 linux `5854ab268a83…`, macOS `2eac1cccdc8a…`, API twice and hashed twice on kasumi; `lupin 0.1.55 (wolf-interp, reference interpreter at pin 294d626)` | none |
| the bundled std | wolf-std `e036bec` | the 0.2.34 archive's `std/STD-REV` reads `e036bec318ad81ecd5a025612bc2c2adb17527f3` | none |
| `[os.fs.sync]` at `v0.2.34` | the builtins | `spec/11-os.md:3445`: `fs_sync(fd) -> () ! {io}` (linux `fsync(2)`, macOS `F_FULLFSYNC`), `fs_sync_dir(path) -> () ! {denied, invalid, io, not_found, unsupported}`; the atomic save is five calls: an EXCLUSIVE create in the target's directory (open mode 4), the write, `fs_sync`, `fs_rename`, `fs_sync_dir`. lupin 0.1.55 resolves neither name (wolf-interp#268) | — |
| ruling #96 D9 | adopt `fs_sync` at 0.2.34 | `crawl-54.md:386`: "the store is written temp-and-rename without fsync until 0.2.34's `fs_sync` (s248, wolf-lang#796), then adopted" | none |
| lope#3 | the four pelt rows at pelt `3b0bab9` | open; `word`, `two`, `here`, `frag` to `/t/beta/gamma`, `/t/projects/myapp`, `/t/alpha`, `/t/beta` (sh21's `notes/sh21-evidence/hooks/expected-sh21.tsv`); and the "pelt cc2fdc9 calls no function" comment in `shell/pelt/jump.sh` | — |
| lope#4 | the README's PAX line | open: `/bin/lope` on PAX, `eval "$(lope init pelt)"` in `/etc/shrc` (`ENV=/etc/shrc`), built by `tools/mkstatic` → pax `tools/mklope`, the store under the user's `HOME` (px54, pax#99) | — |
| pelt | trunk `3b0bab9`, sh21's hook at `90d7c64` and after | `3b0bab9881f5…` is pelt's trunk; `90d7c64` is its ancestor; pelt pins wolf 0.2.32 (its own `wolf-toolchain.toml`); built there on kasumi from its own pin: release 21 s, native 3 s | — |
| the old static digest | lp00's `f9a2f064…` 14,426,728 B | `notes/lp00-the-port.md` §4.6, built twice in `px13-ubuntu` | — |
| kasumi | | `/home` btrfs, 29 GB free; strace, hyperfine, podman, fzf, fish, zsh, fortsh present; `localhost/px13-ubuntu` image `ad8964505189` | — |

A probe before the first change (kasumi, a scratch directory): lupin 0.1.55
runs a program whose module NAMES `fs_sync` in a function it never calls
(`hello 7`, status 0), and refuses at the call (`unsupported: \`fs_sync\` does
not resolve`, status 4). Both compiled tiers at 0.2.34 make the save's calls
as `openat(tmp, O_RDWR|O_CREAT|O_EXCL|O_CLOEXEC, 0666)`, `write`,
`fcntl(F_DUPFD_CLOEXEC)` and `fsync` of the duplicate, `close`,
`openat(".", O_RDONLY|O_CLOEXEC|O_DIRECTORY)`, `fsync`: 4.8 ms each on
kasumi's btrfs (`strace -T`).

## 3. Prediction (before the first change)

1. **The pin.** lope builds at 0.2.34 / 0.1.55 / `e036bec` with
   `--deny-warnings` and no source change: it declares none of the seven new
   prelude names (no W0304), and it reads no terminal mode (bits 5–7 do not
   reach it). Every gate holds with the same numbers: probes 322 of 322,
   corpus 654 of 654, fold 508, cli 95 of 95, import, edit, the hooks; the
   speed ratios within kasumi's noise of lp00's. `wolf test` still runs both
   test files (a file with no `test_*` and a `main` is one test). linux
   aarch64 still builds no tier (wolf-lang#614 is open), so its refusal step
   holds.
2. **The sync.** `save` becomes the spec's five calls: the temporary file
   created exclusively (open mode 4; a stale one of this pid removed and the
   create tried once more), the bytes written through the handle,
   `fs_sync`, the close, `fs_rename` over the store, `fs_sync_dir` of the
   store's directory. An strace census of `lope add` shows exactly that
   order, one `fsync` of the temporary file (by its duplicate) before the
   rename and one of the directory after it, and nothing else synced. At
   trunk's save the same census is red (no `fsync` at all).
3. **The cost.** The two syncs are the whole of it: on kasumi's btrfs about
   5 ms each, so `lope add` (the call every `cd` makes) gets 8–15 ms slower;
   on CI's runner 1–5 ms in all. gump pays one sync (`store.rs:129`,
   `sync_all`), so lope's `add` will be slower than gump's by about one
   sync. `query`, `list` and `init` write nothing: the speed gate does not
   move.
4. **The failure paths.** A failing sync or rename (injected with strace's
   `inject=…:error=EIO`) leaves the old store whole and no temporary file,
   status 1 and `lope: I/O error: Input/output error (os error 5)`. Trunk's
   save loses that reason when its cleanup's `fs_remove` succeeds (it resets
   `os_error()` to 0, `[os.fs.error]`), so it would print "an unknown
   failure"; the new save keeps the number of the step that failed. A
   failing directory sync is after the rename: the new store is in place,
   and the save still says it failed (the move may not survive a crash).
5. **lupin.** `lupin run src/db_test.lu` stays green: the module names the
   two builtins, the test never saves, and lupin resolves at the call.
6. **lope#3.** At pelt `3b0bab9` the four rows read as every other shell's
   (0 of 10 rows differ); with trunk's rows the same session is red on
   exactly `word`, `two`, `here`, `frag`. pelt joins CI's linux job (pelt
   built at its own pin, `pelt.pin`), so the rows are gated there and not
   only on kasumi.
7. **The static build** at the new pin, in `px13-ubuntu`, twice, the same
   bytes, ET_EXEC, no PT_INTERP; its digest is not lp00's `f9a2f064…` (the
   runtime and the store's code changed).

## 4. Evidence index

Every number below was measured; where is named. kasumi's logs are under
`notes/lp01-evidence/` (`kasumi-gauntlet.sh` and `static.sh` are the
scripts that made them).

### 4.1 The pin (`0b28b32`; packaging `afa0882`, `71f8a1c`)

`wolf-toolchain.toml` at wolf 0.2.34 (`9da7bdcf`, `version_line` "wolf
0.2.34 (wolfgang, pin 9da7bdc)"), lupin 0.1.55 (`e642f263`), wolf-std
`e036bec`, every digest as §2 read it. **The gauntlet at the pin alone**
(`kasumi-gauntlet-0b28b32-pin.log`, lope's source unchanged): 26 of 27
statuses 0 — fmt, both generators, the build of both tiers under
`--deny-warnings` (no W0304: lope names none of the seven), `wolf test` (2
passed: each test file's `main`, as 0.2.33), lupin 0.1.55 on both unit
files, probe-check 322 of 322, oracle-check 654 of 654, fold-check, cli-check
95 of 95, import-check, edit-check on both tiers; speed 0.676; selftest. The
one red is the expected one: the hook sessions with pelt at `3b0bab9`
against trunk's rows, red on exactly `word`, `two`, `here`, `frag`
(`hooks-kasumi-0b28b32-pin.tsv`). The packaging: `PKGBUILD` and `.SRCINFO`
at the 0.2.34 x86-64 archive (`88a9dd3d…`) and wolf-std `e036bec`, whose
GitHub archive was downloaded twice (`a7489de8…`, equal; its `std/` is the
release archive's bundled `std/` file for file, the archive adding only
`LICENSE`, `LICENSE-EXCEPTION` and `STD-REV`); `.SRCINFO` equals what
`makepkg --printsrcinfo` writes from the `PKGBUILD` (Arch's
`base-devel` image on kasumi, as a user: `diff` empty). `lope.rb` names
0.2.34. lope's own tag digest stays the release lane's.

### 4.2 The sync (`093e825`; the census `03a2873`, `ee4cbea`)

`src/db/store.lu`'s `save` is `[os.fs.sync]`'s five calls: the temporary
file created exclusively (`fs_open_mode(tmp, 4)`; a file of that name, an
earlier process's with this pid, removed and the create made again), the
bytes written through the handle (`fs_write_chunk`, `write_all` in the
runtime), `fs_sync`, `fs_close`, `fs_rename`, `fs_sync_dir` of the store's
directory. It answers the host's number of the step that failed (cmd's
message prints it): trunk's lost it when its cleanup's `fs_remove`
succeeded, measured below. One save, as strace sees it (release and
static the same calls, `save-release.trace`, `save-static.trace`):

    openat(AT_FDCWD, ".../store.tmp.965194", O_RDWR|O_CREAT|O_EXCL|O_CLOEXEC, 0666) = 3
    write(3, "lope-store 1\ncleanup 17926208076"..., 183) = 183
    fcntl(3, F_DUPFD_CLOEXEC, 3)     = 4
    fsync(4)                         = 0 <0.012144>
    close(4) / close(3)
    rename(".../store.tmp.965194", ".../store") = 0
    openat(AT_FDCWD, ".../lope", O_RDONLY|O_CLOEXEC|O_DIRECTORY) = 3
    fsync(3)                         = 0 <0.014356>

**`tools/sync-census`** (strace; seven rows, each seen red first):

| row | at the head (kasumi, both tiers, static; CI both tiers) | the pin's lope (trunk's save at 0.2.34), kasumi | the plant, CI 39684817118 |
|---|---|---|---|
| first, again | open-excl, write, sync of the file, rename, open-dir, sync of the dir; every byte; no temporary left | `open-tmp-not-exclusive write-tmp rename`: no sync | no sync of the file |
| stale | EEXIST, unlink, then as `again` | not exclusive, no sync | no sync of the file |
| fault-write (ENOSPC) | status 1, `No space left on device (os error 28)`, old store, no temporary | status 1, but **1 temporary left** | ok (the plant leaves the write's cleanup) |
| fault-sync (EIO, first sync) | status 1, `Input/output error (os error 5)`, old store | status 0: no sync to fail | status 1 with the NEW store: the first sync was the directory's |
| fault-rename (EIO) | status 1, `(os error 5)`, old store | status 1, **"an unknown failure"** (the reason lost, prediction 4) | ok |
| fault-dir (EIO, second sync) | status 1, `(os error 5)`, the new store in place | status 0 | status 0: no second sync |

The pin's lope: 7 of 7 rows red (kasumi, `tools/sync-census
../scratch/lp01-lope-pin-release`, status 1). The plant (`lp01-plant`,
`09ce47a`: the file's sync dropped, nothing else in `src/`): 5 rows red in
CI run **39684817118**, job 119516123771, step "the store's syncs, seen in
its system calls, both tiers". selftest's new row (`nosave`: an `add` that
saves nothing) red as planted, in every run (kasumi and CI). lupin 0.1.55
runs `src/db_test.lu` green (prediction 5): it resolves at the call and the
test never saves. On PAX the save's calls are served: `fsync` answers 0 for
a file or a directory (pax `kernel/files/files.lu:4437`), `F_DUPFD_CLOEXEC`
(`files.lu:1011`), `O_EXCL` and `O_DIRECTORY` opens, `rename`.

### 4.3 The cost per save (`docs/STORE.md`, `cost/`)

The two syncs are the whole of it. kasumi (btrfs on nvme), load about 3:
the file's sync 4.97 ms, the directory's 4.94 (strace -T medians); `lope
add` 10.40 ms against 0.82 for the pin's lope (no syncs), interleaved, 15
runs, `taskset -c 0-3`: **+9.6 ms per save**. kasumi loaded (8–12, other
lanes' jobs), five runs of 31: syncs 6.2–11.7 and 9.7–15.0 ms, **+16.6 to
+42.4 ms** (`cost-1..5.json`). CI's runner (ext4, run 39684417699): 0.43–0.47
and 0.22–0.23 ms, `lope add` 2.03–2.06 ms. Against gump's `add` (one sync)
on kasumi, loaded, interleaved, 31 runs: lope 20.00 / 30.98 ms, gump 10.89 /
15.55 (`cost-gump-1,2.json`): one sync more, as predicted. The prediction's
8–15 ms held on an unloaded host; under load kasumi's flush is slower.
`query` writes nothing: the speed gate at the head 0.544 on kasumi
(`speed-kasumi-8872c7e.json`), 0.648 in CI (39684417699).

### 4.4 lope#3: pelt's rows (`1d35ecf`, `7ee571d`, `1c3ad57`; ci `8872c7e`)

`pelt.pin` names pelt `3b0bab9` (sh21's hook since `90d7c64`);
`tools/fetch-pelt` builds it from its own tree with its own pinned wolf
(0.2.32), and CI's linux job now runs the pelt sessions (before lp01 the
pelt rows were checked on kasumi only). At the head, pelt's ten rows are
every other shell's, 0 rows differ: kasumi (`hooks-kasumi-8872c7e.tsv`,
lope and gump in bash, zsh, fish, fortsh and pelt) and CI 39684417699 (step
"the hooks on PTYs (pelt at pelt.pin)"). Seen red: at the pin with trunk's
rows (§4.1), and in the plant run **39684817118** (job 119516123771, the
rows put back to cc2fdc9's answers): exactly `word`, `two`, `here`, `frag`.
`shell/pelt/jump.sh`'s "pelt cc2fdc9 calls no function" note is gone (and
`src/cmd/pieces.lu`, generated from it). `pelt.pin` is a `pr` path in the
planner (`ci/tiers.py`; its test row red without the rule on kasumi and in
the plant run, job 119516123712: `FAIL T2 the pins are pr`).

### 4.5 lope#4: the README

"On PAX" (`4df0071`): `/bin/lope`, built by pax's `tools/mklope` from this
tree at `user/lope.pin`'s commit with this tree's toolchain, as
`tools/mkstatic` builds it; `/etc/shrc` (pelt's `ENV`) runs `eval "$(lope
init pelt)"`; the store under the user's `HOME` (`/.local/share/lope/store`
for root), in PAX's in-memory tree; `gi`'s menu (no fzf). The same commit
moves the hooks table's pelt row to what is measured: `cd` as a function
(or `PS1`), the jump by `command_not_found_handle`, pelt `3b0bab9`.

### 4.6 The static build

`tools/mkstatic` in `localhost/px13-ubuntu` (image `ad8964505189…`: Ubuntu
24.04.5, libc6-dev 2.39-0ubuntu8.9, gcc 13.3.0) on kasumi, from clean clones
at `ff0fdfb` (src/ final since `7ee571d`), twice, the same bytes
(`static-ff0fdfb.log`): **`lope f6c040e4d041b433f6b959f7978bd166ea1d40a7358ff2f06d3ab4d3b071f888
15065128`**, ET_EXEC, statically linked, no PT_INTERP, `lope 0.1.0`; the
sync census (7 of 7), oracle-check (654 of 654), cli-check (95 of 95) and
edit-check hold on it. CI's runner builds its own from the same tree with
its libc (run 39684417699: `64ca1fcc309ef51eb25dc931607573e316c6b76de113cabee5b970bf16c28c20
14819400`), so the next pax pin names the image with the digest. lp00's was
`f9a2f064…` 14,426,728; px57 ships that one, and the move is a later px
lane's.

### 4.7 The kasumi gauntlet at the head's code

`kasumi-gauntlet-8872c7e.log` (`8872c7e`: every source, tool, test and
workflow change of the lane; later commits are prose): 27 statuses read
directly, all 0, including the sync census on both tiers, `tools/fetch-pelt`,
the hook sessions in bash, zsh, fish, fortsh and pelt for lope and gump
(0 rows differ), speed and selftest (seven planted reds, the census's
among them).

### 4.8 CI runs

| run | head | what | result |
|---|---|---|---|
| 39684417699 | `ff0fdfb` | PR #5, `tier pr` | green: every gate on linux x86-64, the census both tiers, pelt's sessions |
| **39684817118** | `09ce47a` (`lp01-plant`) | PLANT, dispatch `-f jobs="plan-test linux"`, `tier partial` | red as planted: plan-test (T2's pins row), the sync census (5 rows, native), pelt's sessions (the four rows); every other gate green |
| (PR #5's body) | the final head | `tier pr`, then `full-matrix`, `tier full` | named in the PR's body: a commit cannot carry its own run's id |

## 5. Done-when

- The pin in its own commit (`0b28b32`); the packaging at the 0.2.34
  archive and std `e036bec` (`afa0882`, `71f8a1c`).
- The sync (`093e825`), its row (`tools/sync-census`, CI both tiers) and the
  cost per save stated (§4.3, `docs/STORE.md`).
- lope#3's rows real against pelt `3b0bab9`, gated in CI (§4.4).
- lope#4's PAX section (§4.5).
- The static digest at the new pin (§4.6).
- Every new row seen red before green (§4.2, §4.4; plant run 39684817118).
- PR #5 with the five sections, the shas, a checklist; `tier pr` green at
  the final head, the `full-matrix` label there, `lane-audit.sh lope lp01 5`
  run; the `tier full` run id in the hand-back.

## 6. Issues

- To close on the merge, by hand: **lope#3** (the four rows, §4.4) and
  **lope#4** (the README, §4.5).
- To file: none needed by lope. For the record: lupin 0.1.55 does not
  resolve `fs_sync`/`fs_sync_dir` (wolf-interp#268, already filed; lupin
  0.1.56 mirrors them, is79), so lope's lupin column runs only the unit
  files, which never save.
- For the next pax lane (px57's successor): lope's static digest
  `f6c040e4…` 15,065,128 B in `px13-ubuntu` `ad8964505189`.
