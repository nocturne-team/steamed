#!/usr/bin/env bash
# Swaps each freshly built jar for the previous release's jar of the same node when their contents match (version
# aside), so a node only gets a new version when something in it changed. Needs GH_TOKEN and GH_REPO.
# Usage: reuse-unchanged.sh <jars dir> <current tag>
set -euo pipefail
jars="$1" tag="$2"
here="$(dirname "$0")"

previous="$(gh release list --exclude-drafts --limit 20 --json tagName -q '.[].tagName' | grep -vxF "$tag" | head -n1 || true)"
if [ -z "$previous" ]; then echo "No previous release, keeping every jar"; exit 0; fi

old="$(mktemp -d)"
gh release download "$previous" -D "$old" -p 'steamed-*.jar'

for path in "$jars"/steamed-*.jar; do
  jar="$(basename "$path")"                 # steamed-fabric-0.2.0+26.2.jar
  loader="${jar#steamed-}"; loader="${loader%%-*}"
  mc="${jar##*+}"; mc="${mc%.jar}"
  match=("$old"/steamed-"$loader"-*+"$mc".jar)
  if [ ! -f "${match[0]}" ]; then echo "$jar: new node"; continue; fi
  if python3 -I "$here/same_jar.py" "${match[0]}" "$path"; then
    echo "$jar: unchanged, reusing $(basename "${match[0]}")"
    rm "$path" && cp "${match[0]}" "$jars/"
  else
    echo "$jar: changed"
  fi
done
