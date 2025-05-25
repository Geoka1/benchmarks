#!/bin/bash
# tag: count_trigrams.sh
# set -e


IN=${IN:-$SUITE_DIR/inputs/pg}
OUT=${1:-$SUITE_DIR/outputs/4_3b/}
ENTRIES=${ENTRIES:-1000}
mkdir -p "$OUT"

pure_func() {
    input=$1
    mkfifo "$input"p1 "$input"p2
    tr -c 'A-Za-z' '[\n*]' < "$IN/$input" | grep -v "^\s*$" | tee "$input"p1 "$input"p2 | paste - <(tail -n +2 "$input"p1) <(tail -n +2 "$input"p2) | sort | uniq -c
    rm "$input"p1 "$input"p2
}

export -f pure_func

# Parallelize the processing
job_count=0
MAX_PROCS=$(nproc)
for input in $(ls "$IN" | head -n "$ENTRIES"); do
    {
        pure_func "$input" > "${OUT}/${input}.trigrams"
    } &

    ((job_count++))
    if (( job_count >= MAX_PROCS )); then
        wait -n
        ((job_count--))
    fi
done

wait
echo 'done'