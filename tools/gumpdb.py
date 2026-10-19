#!/usr/bin/env python3
"""gumpdb — write and read gump's db.bin (bincode 1, fixint, little-endian).

Layout observed from a db.bin gump 0.2.7 wrote (and bincode 1's documented
encoding): u32 version; u64 entry count; per entry: u64 len + path bytes,
f64 score, u64 len + RFC 3339 last_accessed, u64 access_count; then
u64 len + RFC 3339 last_cleanup.
"""
import json, struct, sys, time, datetime

def rfc3339(ms):
    dt = datetime.datetime.fromtimestamp(ms / 1000.0, tz=datetime.timezone.utc)
    return dt.strftime("%Y-%m-%dT%H:%M:%S.") + "%09d" % (dt.microsecond * 1000) + "Z"

def s(b):
    return struct.pack("<Q", len(b)) + b

def write(entries, path, now_ms=None, cleanup_ms=None):
    now_ms = now_ms if now_ms is not None else int(time.time() * 1000)
    out = struct.pack("<I", 1) + struct.pack("<Q", len(entries))
    for e in entries:
        out += s(e["path"].encode())
        out += struct.pack("<d", float(e["score"]))
        out += s(rfc3339(now_ms - int(e.get("age_s", 0) * 1000)).encode())
        out += struct.pack("<Q", int(e.get("count", 1)))
    out += s(rfc3339(cleanup_ms if cleanup_ms is not None else now_ms).encode())
    with open(path, "wb") as f:
        f.write(out)

def read(path):
    b = open(path, "rb").read()
    o = 0
    def u(fmt):
        nonlocal o
        v = struct.unpack_from(fmt, b, o)[0]; o += struct.calcsize(fmt); return v
    def st():
        nonlocal o
        n = u("<Q"); v = b[o:o + n].decode(); o += n; return v
    ver = u("<I"); n = u("<Q"); es = []
    for _ in range(n):
        p = st(); sc = u("<d"); la = st(); c = u("<Q")
        es.append({"path": p, "score": sc, "last": la, "count": c})
    return {"version": ver, "entries": es, "last_cleanup": st(), "rest": len(b) - o}

if __name__ == "__main__":
    if sys.argv[1] == "write":
        write(json.load(open(sys.argv[2])), sys.argv[3])
    else:
        print(json.dumps(read(sys.argv[2]), indent=1))
