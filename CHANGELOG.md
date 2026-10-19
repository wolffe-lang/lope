# Changelog

## 0.1.0 (unreleased) — lp00, the port

gump 0.2.7 (`43c114d`) ported to wolf 0.2.33 and renamed lope.

- Every gump command: `add`, `query` (`-s`, `-a`, `--cwd`), `remove`,
  `list` (`-s`), `clean`, `init SHELL` (`--cmd`, `--hook`, `--no-cmd`),
  `import`, `edit`; gump's clap messages and statuses (95 recorded
  command lines).
- The store: gump's frecency rule, aging and clean rule, in lope's own
  versioned text format, written atomically (temp, rename; wolf has no
  `fsync`). `import` reads gump's `db.bin` whole.
- The matcher, clean-room: a Smith-Waterman alignment with gump's
  constants as the binary answers them; 322 of 322 probe rows, 654 of 654
  corpus cases (164 inside gump's random ties).
- Hooks for bash, zsh, fish, fortsh and pelt. bash's no-prefix jump works
  (gump's runs in a subshell and stays put); `gi` falls back to a
  numbered menu without fzf; pelt's no-prefix jump waits on a pelt hook.
- Speed gated in CI: `query` no slower than gump's.
- Packaging prepared (Homebrew, AUR, RPM), not published; a static
  x86-64 build for PAX.
