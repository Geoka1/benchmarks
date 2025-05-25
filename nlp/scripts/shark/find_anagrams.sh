#!/bin/bash
# tag: find_anagrams.sh

IN=${IN:-$SUITE_DIR/inputs/pg}
OUT=${1:-$SUITE_DIR/outputs/8.3_2/}
ENTRIES=${ENTRIES:-1000}
MAX_PROCS=${MAX_PROCS:-$(nproc)}
mkdir -p "$OUT"

pure_func() {
    input=$1
    infile=$2
    tmpfile=$(mktemp)

    sort -u "$infile" > "$tmpfile"

    # need a tempfile for correctness
    rev "$tmpfile" > "${tmpfile}.rev"
    sort "$tmpfile" "${tmpfile}.rev" | uniq -c | awk '$1 >= 2 {print $2}'

    rm -f "$tmpfile" "${tmpfile}.rev"
}
export -f pure_func

job_count=0

for input in $(ls "$IN" | head -n "$ENTRIES"); do
    {
        tmp_input=$(mktemp)
        tr -c 'A-Za-z' '[\n*]' < "$IN/$input" | grep -v "^\s*$" > "$tmp_input"
        pure_func "$input" "$tmp_input" > "$OUT/${input}.out"
        rm -f "$tmp_input"
    } &

    ((job_count++))
    if (( job_count >= MAX_PROCS )); then
        wait -n
        ((job_count--))
    fi
done

wait
echo 'done'
