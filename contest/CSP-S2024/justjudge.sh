#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Author: Bingwu Zhang <xtex@xtexx.eu.org>
set -euo pipefail
t=$1
g++ "$t".cpp -O2 -std=c++14 -static

for d in ../../c/"$t"/"$t"*.ans; do
echo "===== $d"
[[ "$d" = *4* ]] && continue
cp "$d" "$t".ans
cp "${d%%.ans}".in "$t".in
time ./a.out
# cat "$t".out | cut -d' ' -f1 > "$t".out1
# cat "$t".ans | cut -d' ' -f1 > "$t".ans1
# diff "$t".out1 "$t".ans1 || true
diff "$t".out "$t".ans || true
done
