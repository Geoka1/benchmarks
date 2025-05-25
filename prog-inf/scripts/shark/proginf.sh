#!/bin/bash
TOP=$(realpath "$(dirname "$0")/..")
MIR_BIN=$TOP/inputs/mir-sa/@andromeda/mir-sa/index.js
OUT=$TOP/outputs
IN=$TOP/inputs
INDEX=${INDEX:-"$TOP/inputs/index.txt"}

mkdir -p "${OUT}/"
current_jobs=0
pkg_count=0
MAX_PROCS=${MAX_PROCS:-$(nproc)}
while read -r package; do
    pkg_count=$((pkg_count + 1))

    (
        cd "$IN/node_modules/$package" || exit 1
        "$MIR_BIN" -p > "$OUT/$pkg_count.log"
    ) &

    ((current_jobs++))
    if (( current_jobs >= MAX_PROCS )); then
        wait -n   # wait for any job to finish
        ((current_jobs--))
    fi
done < "$INDEX"

wait