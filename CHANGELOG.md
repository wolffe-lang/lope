# Changelog

## Unreleased

- `lope init pelt` enables pelt's `autocd` option with an old-pelt-safe
  subshell guard. In an interactive PAX shell, slashed directory words such
  as `home/pax` and `/home/pax/` now change directory; the existing
  command-not-found hook still resolves bare fuzzy words.

## 0.1.0 (unreleased) — lp00, the port; lp01, the sync and the pin

gump 0.2.7 (`43c114d`) ported to wolf 0.2.33 and renamed lope (lp00);
moved to wolf 0.2.34 / lupin 0.1.55 / wolf-std `e036bec` (lp01).

- Every gump command: `add`, `query` (`-s`, `-a`, `--cwd`), `remove`,
  `list` (`-s`), `clean`, `init SHELL` (`--cmd`, `--hook`, `--no-cmd`),
  `import`, `edit`; gump's clap messages and statuses (95 recorded
  command lines).
- The store: gump's frecency rule, aging and clean rule, in lope's own
  versioned text format, written atomically and durably: the temporary
  file created exclusively, synced, renamed over the store, and the
  directory synced (wolf 0.2.34's `fs_sync`, `fs_sync_dir`; ruling #96
  D9, lp01). A failed save keeps the old store and says the failing
  step's reason. `import` reads gump's `db.bin` whole.
- The matcher, clean-room: a Smith-Waterman alignment with gump's
  constants as the binary answers them; 322 of 322 probe rows, 654 of 654
  corpus cases (164 inside gump's random ties).
- Hooks for bash, zsh, fish, fortsh and pelt. bash's no-prefix jump works
  (gump's runs in a subshell and stays put); `gi` falls back to a
  numbered menu without fzf; pelt's no-prefix jump works at pelt
  `3b0bab9` (its `command_not_found_handle`, sh21), gated in CI (lp01).
- Speed gated in CI: `query` no slower than gump's.
- Packaging prepared (Homebrew, AUR, RPM), not published; a static
  x86-64 build for PAX, where lope is preinstalled as `/bin/lope` (px54).
