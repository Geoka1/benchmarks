#!/bin/bash
# tag: sort_words_by_num_of_syllables
# set -e

IN=${IN:-$SUITE_DIR/inputs/pg}
OUT=${1:-$SUITE_DIR/outputs/8.1/}
ENTRIES=${ENTRIES:-1000}
mkdir -p "$OUT"

pure_func() {
    input=$1
    mkfifo "$input"p1
    tee "$input"p1 | tr -sc '[AEIOUaeiou\012]' ' ' | awk '{print NF}' | paste - "$input"p1 | sort -nr | sed 5q
    rm "$input"p1
}
job_count=0

for input in $(ls "$IN" | head -n "$ENTRIES"); do
    {
        tr -c 'A-Za-z' '[\n*]' < "$IN/$input" | grep -v "^\s*$" | sort -u \
            | pure_func "$input" > "$OUT/${input}.out"
    } &

    ((job_count++))
    if (( job_count >= MAX_PROCS )); then
        wait -n
        ((job_count--))
    fi
done

wait
echo 'done'