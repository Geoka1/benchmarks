#!/bin/bash
# tag: trigram_rec
# set -e


IN=${IN:-$SUITE_DIR/inputs/pg}
OUT=${1:-$SUITE_DIR/outputs/6_1/}
ENTRIES=${ENTRIES:-1000}
mkdir -p "$OUT"

pure_func() {
    input=$1
    mkfifi "$input"p1 "$input"p2
    tr -sc '[A-Z][a-z]' '[\012*]' | tee "$input"p1 "$input"p2 | paste - <(tail +2 "$input"p1) <(tail +3 "$input"p2) | sort | uniq -c
    rm "$input"p1 "$input"p2
}
export -f pure_func

job_count=0

for input in $(ls "$IN" | head -n "$ENTRIES" | xargs -I arg1 basename arg1); do
    {
        grep 'the land of' "$IN/$input" | pure_func "$input" | sort -nr | sed 5q > "$OUT/${input}.0.out"
    } &
    ((job_count++))
    if (( job_count >= MAX_PROCS )); then
        wait -n
        ((job_count--))
    fi

    {
        grep 'And he said' "$IN/$input" | pure_func "$input" | sort -nr | sed 5q > "$OUT/${input}.1.out"
    } &
    ((job_count++))
    if (( job_count >= MAX_PROCS )); then
        wait -n
        ((job_count--))
    fi
done
wait

echo 'done';