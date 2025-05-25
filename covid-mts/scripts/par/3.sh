#!/bin/bash
# Hours each vehicle is on the road

# Using GNU parallel:

INPUT="$1"

MAX_PROCS=${MAX_PROCS:-$(nproc)}
chunk_size=${chunk_size:-100M}
process_chunk() {
  sed 's/T\(..\):..:../,\1/' |  
  cut -d ',' -f 1,2,4                  
}
export -f process_chunk

tmp_dir=$(mktemp -d)
trap "rm -rf $tmp_dir" EXIT  

cat "$INPUT" |
  parallel --pipe --block "$chunk_size" -j "$MAX_PROCS" process_chunk > "$tmp_dir/combined.tmp"

sort -u "$tmp_dir/combined.tmp" |
  cut -d ',' -f 3 |               
  sort |                         
  uniq -c |                      
  sort -k 1 -n |                 
  awk '{print $2,$1}'             
