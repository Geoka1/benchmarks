#!/bin/bash
# source: posh benchmark suite

input="$1"
dest="$2"
count=0
for file in "$input"/*.jpg; do
    [ -e "$file" ] || continue

    mogrify -format gif -path "$dest" -thumbnail 100x100 "$file" &

    count=$((count + 1))
    if [ "$count" -ge "$MAX_PROCS" ]; then
        wait
        count=0
    fi
done

wait