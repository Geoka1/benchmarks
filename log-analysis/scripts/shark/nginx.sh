#!/bin/bash

mkdir -p "$2"

pure_func() {
    log="$1"
    out="$2"

    fifo_dir=$(mktemp -d)
    for i in {1..8}; do mkfifo "$fifo_dir/fifo$i"; done

    {
        cut -d "\"" -f3 < "$fifo_dir/fifo1" | cut -d ' ' -f2 | sort | uniq -c | sort -rn
        awk '{print $9}' "$fifo_dir/fifo2" | sort | uniq -c | sort -rn
        awk '($9 ~ /404/)' "$fifo_dir/fifo3" | awk '{print $7}' | sort | uniq -c | sort -rn
        awk '($9 ~ /502/)' "$fifo_dir/fifo4" | awk '{print $7}' | sort | uniq -c | sort -r
        awk -F\" '($2 ~ "/wp-admin/install.php"){print $1}' "$fifo_dir/fifo5" | awk '{print $1}' | sort | uniq -c | sort -r
        awk '($9 ~ /404/)' "$fifo_dir/fifo6" | awk -F\" '($2 ~ "^GET .*.php")' | awk '{print $7}' | sort | uniq -c | sort -r | head -n 20
        awk -F\" '{print $2}' "$fifo_dir/fifo7" | awk '{print $2}' | sort | uniq -c | sort -r
        awk -F\" '($2 ~ "ref"){print $2}' "$fifo_dir/fifo8" | awk '{print $2}' | sort | uniq -c | sort -r
    } > "$out" &

    # Broadcast input log to all FIFOs
    tee "${fifo_dir}"/fifo{1..8} < "$log" > /dev/null

    wait
    rm -rf "$fifo_dir"
}
export -f pure_func

for log in "$1"/*; do
    [ -f "$log" ] || continue
    out_file="$2/$(basename "$log")"
    pure_func "$log" "$out_file" &
done

wait