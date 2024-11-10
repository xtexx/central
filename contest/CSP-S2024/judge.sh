#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Author: Bingwu Zhang <xtex@xtexx.eu.org>
set -euo pipefail
t=$1
g++ "$t".cpp -O2 -std=c++14 -static

for d in ../../c/"$t"/"$t"*.ans; do
echo "===== $d"
cp "$d" "$t".ans
cp "${d%%.ans}".in "$t".in
time ./a.out
diff "$t".out "$t".ans
done
