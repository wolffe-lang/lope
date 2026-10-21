#!/bin/bash
# lp01's static build: lope at SHA built twice from clean clones in
# localhost/px13-ubuntu (never kasumi's host glibc), by tools/mkstatic,
# the archives by digest from a read-only mount. usage: lp01-static.sh SHA TAG
set -u
L=$HOME/lanes/lp01; SHA=$1; T=$2
podman image inspect localhost/px13-ubuntu --format 'image {{.Id}}'
for n in 1 2; do
  d=$L/scratch/static-$T-$n
  rm -rf "$d"
  git clone -q "$L/lope" "$d" && git -C "$d" checkout -q --detach "$SHA" || { echo "clone $n failed"; exit 2; }
  echo "build $n at $(git -C "$d" rev-parse HEAD)"
  podman run --rm -v "$d:/src" -v "$L/archives:/archives:ro" -e LOPE_ARCHIVE_DIR=/archives localhost/px13-ubuntu \
    bash -c 'ulimit -c 0; cd /src && tools/fetch-toolchain && tools/mkstatic /src/target/static' > "$L/scratch/static-$T-$n.log" 2>&1
  echo "build $n status $?"
  cat "$d/target/static/sums.txt"
  tail -2 "$L/scratch/static-$T-$n.log"
done
cmp "$L/scratch/static-$T-1/target/static/lope" "$L/scratch/static-$T-2/target/static/lope" && echo "the two builds: the same bytes"
echo done
