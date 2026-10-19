#!/bin/bash
# lp00's kasumi gauntlet: every gate at the synced head, both tiers, statuses read directly
cd ~/lanes/lp00/lope || exit 2
echo "head $(git rev-parse HEAD) $(date -u +%FT%TZ) $(uptime)"
st() { "$@"; echo "== status $? : $*"; }
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
done
st python3 tools/hook-sessions --tool lope=target/release/lope --tool gump=$HOME/lanes/lp00/gump/target/release/gump --pelt $HOME/lanes/lp00/pelt/target/release/pelt --expect tests/hooks/expected.tsv --report $HOME/lanes/lp00/scratch/hooks-final.tsv --logs $HOME/lanes/lp00/scratch/hooks-final-logs
st tools/speed target/release/lope .gump/target/release/gump --runs 31 --report $HOME/lanes/lp00/scratch/speed-final.json
st tools/selftest target/release/lope
echo "done $(date -u +%FT%TZ)"
