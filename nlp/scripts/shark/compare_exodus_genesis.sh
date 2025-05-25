#!/bin/bash
# tag: compare_exodus_genesis_fifo_safe
# set -e

IN=${IN:-$SUITE_DIR/inputs/pg}
INPUT2=${INPUT2:-$SUITE_DIR/inputs/exodus}
OUT=${1:-$SUITE_DIR/outputs/8.3_3/}
ENTRIES=${ENTRIES:-1000}
mkdir -p "$OUT"

# Precompute Exodus types into a temp file
EXODUS_TMP=$(mktemp)
tr -sc '[A-Z][a-z]' '[\012*]' < "$INPUT2" | sort -u > "$EXODUS_TMP"

pure_func() {
    input="$1"
    outfile="$OUT/${input}.out"
    infile="$IN/$input"

    gfifo="/tmp/genesis_fifo_${input}_$$"
    mkfifo "$gfifo"

    # Write Genesis stream into FIFO
    (
        tr -c 'A-Za-z' '[\n*]' < "$infile" |
        grep -v '^\s*$' |
        sort -u > "$gfifo"
    ) &

    # Use Exodus types from the buffered file
    sort "$gfifo" "$EXODUS_TMP" "$EXODUS_TMP" |
        uniq -c | head > "$outfile"

    rm -f "$gfifo"
}
export -f pure_func

for input in $(ls "$IN" | head -n "$ENTRIES"); do
    pure_func "$input" &
done

wait
rm -f "$EXODUS_TMP"
echo 'done'
