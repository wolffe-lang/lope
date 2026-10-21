#!/bin/bash
# lp01's kasumi gauntlet: every gate at the synced head, both tiers, each
# status read directly (lp00's, with pelt at pelt.pin's commit and the
# sync census). usage: kasumi-gauntlet.sh TAG
T=${1:?usage: kasumi-gauntlet.sh TAG}
L=$HOME/lanes/lp01
S=$L/scratch/$T
mkdir -p "$S"
export TMPDIR=$L/scratch/tmp
mkdir -p "$TMPDIR"
cd "$L/lope" || exit 2
echo "head $(git rev-parse HEAD) $(date -u +%FT%TZ) $(uptime)"
st() { "$@"; echo "== status $? : $*"; }
st tools/fetch-toolchain
st tools/check-fmt
st python3 tools/gen-hooks --check
st python3 tools/gen-fold --check
st tools/build --all
st tools/check-test
st .wolf-bin/lupin run src/matcher_test.lu
st .wolf-bin/lupin run src/db_test.lu
for t in native release; do
  st tools/probe-check target/$t/lope
  st tools/oracle-check target/$t/lope
  st tools/fold-check target/$t/lope
  st tools/cli-check target/$t/lope
  st tools/import-check target/$t/lope
  st tools/edit-check target/$t/lope
  [ -x tools/sync-census ] && st tools/sync-census target/$t/lope --report "$S/sync-$t.json"
done
[ -x tools/fetch-pelt ] && st tools/fetch-pelt
pelt=$L/lope/.pelt/target/release/pelt
[ -x "$pelt" ] || pelt=$L/pelt/target/release/pelt
st python3 tools/hook-sessions --tool lope=target/release/lope --tool gump=.gump/target/release/gump \
  --pelt "$pelt" --expect tests/hooks/expected.tsv \
  --report "$S/hooks.tsv" --logs "$S/hooks-logs"
[ -x tools/sync-census ] && [ -x "$L/scratch/lp01-lope-pin-release" ] && \
  st tools/sync-census target/release/lope --against "$L/scratch/lp01-lope-pin-release" --runs 31 --report "$S/sync-cost.json"
st tools/speed target/release/lope .gump/target/release/gump --runs 31 --report "$S/speed.json"
st tools/selftest target/release/lope
echo "done $(date -u +%FT%TZ)"
