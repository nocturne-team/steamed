#!/usr/bin/env python3
# Exit 0 when two Steamed jars hold the same files, ignoring the mod version in the loader metadata.
# Usage: same_jar.py <old.jar> <new.jar>
import re
import sys
import zipfile

METADATA = {"fabric.mod.json", "META-INF/neoforge.mods.toml", "META-INF/mods.toml"}


def version_of(path):
    # steamed-fabric-0.2.0+26.2.jar -> 0.2.0
    return re.match(r"steamed-[a-z]+-(.+)\+[^+]+\.jar$", path.rsplit("/", 1)[-1]).group(1)


def contents(path):
    version = version_of(path).encode()
    with zipfile.ZipFile(path) as jar:
        files = {}
        for info in jar.infolist():
            if info.is_dir():
                continue
            data = jar.read(info)
            if info.filename in METADATA:
                data = data.replace(version, b"<version>")
            files[info.filename] = data
        return files


old, new = contents(sys.argv[1]), contents(sys.argv[2])
changed = sorted(name for name in old.keys() | new.keys() if old.get(name) != new.get(name))
for name in changed[:20]:
    print(f"  differs: {name}", file=sys.stderr)
sys.exit(1 if changed else 0)
