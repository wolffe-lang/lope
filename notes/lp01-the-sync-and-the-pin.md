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
