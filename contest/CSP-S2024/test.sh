#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Author: Bingwu Zhang <xtex@xtexx.eu.org>
set -euo pipefail
t=$1
g++ "$t".cpp -O2 -std=c++14 -static
if [[ -n "$2" ]]; then
cp ../../c/"$t"/"$t$2".ans "$t".ans
cp ../../c/"$t"/"$t$2".in "$t".in
fi
time ./a.out
diff "$t".out "$t".ans
