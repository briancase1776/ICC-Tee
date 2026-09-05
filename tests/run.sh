#!/bin/sh
# Prove the tee: hold three FIFOs, tee one into the other two, push bytes
# in, see them all arrive on both in order, remove it.
set -eu
cd "$(dirname "$0")/../.claude/skills/icc-tee"
w=$(mktemp -d)
trap 'rm -rf "$w"' EXIT
mkfifo "$w/in" "$w/a" "$w/b"
exec 3<>"$w/in" 4<>"$w/a" 5<>"$w/b"
! scripts/create "$w/in" 2>/dev/null
! scripts/create "$w/in" "$w/none" 2>/dev/null
d=$(scripts/create "$w/in" "$w/a" "$w/b")
trap 'scripts/remove "$d" 2>/dev/null || :; rm -rf "$w"' EXIT
scripts/list | grep -qx "$d up $w/in $w/a $w/b"
printf 'one\n' > "$w/in"
printf 'two\n' > "$w/in"
for o in a b; do [ "$(timeout 1 cat "$w/$o")" = "$(printf 'one\ntwo')" ]; done
p=$(cat "$d/pid")
scripts/remove "$d"
[ ! -d "$d" ]
! kill -0 "$p" 2>/dev/null
[ -p "$w/in" ] && [ -p "$w/a" ] && [ -p "$w/b" ]
trap 'rm -rf "$w"' EXIT
echo ok
