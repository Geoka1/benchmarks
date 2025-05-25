#!/bin/bash
# source: posh benchmarks

in_dir=$1
out_dir=$2
mkdir -p "$out_dir"

grep "\[RAY\]" "$in_dir/1.INFO" | head -n1 | cut -c 7- > "$out_dir/rays.csv"

tmpdir=$(mktemp -d)
i=0
for file in "$in_dir"/*.INFO; do
    {
        fifo="$tmpdir/fifo_$i"
        outfile="$tmpdir/out_$i"
        mkfifo "$fifo"
        cat < "$fifo" > "$outfile" &

        grep "\[RAY\]" "$file" | grep -v pathID | cut -c 7- > "$fifo"

        wait 
        rm "$fifo"
    } &
    ((i++))
done

wait  

cat "$tmpdir"/out_* >> "$out_dir/rays.csv"
rm -r "$tmpdir"

sed -n '/^590432,/p' "$out_dir/rays.csv" > "$out_dir/rt.log"