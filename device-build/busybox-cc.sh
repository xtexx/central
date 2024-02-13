#!/usr/bin/env bash

# CC wrapper for building busybox

args=("$@")
newArgs=()

for arg in "${args[@]}"; do
    [[ "$arg" == "-Wl,--warn-common" ]] && continue
    [[ "$arg" == "-Wl,--verbose" ]] && continue
    [[ "$arg" =~ -Wl,-Map,.* ]] && continue
    # https://github.com/ziglang/zig/issues/9948
    [[ "$arg" =~ -Wp,-MD,.* ]] && {
        newArgs=("${newArgs[@]}" "-MD" "-MF" "${arg/-Wp,-MD,/}")
        continue
    }
    newArgs=("${newArgs[@]}" "$arg")
done

newArgs=("${newArgs[@]}" "-lc" "-Wno-ignored-optimization-argument")

exec "${newArgs[@]}"
