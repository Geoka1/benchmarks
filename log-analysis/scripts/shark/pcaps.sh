#!/bin/bash

mkdir -p "$2"

pure_func() {
    infile="$1"
    outfile="$2"

    fifo=$(mktemp -u)
    mkfifo "$fifo"

    tee "$fifo" < "$infile" > /dev/null &

    {
        tcpdump -nn -r "$fifo" -A 'port 53' 2>/dev/null | sort | uniq | grep -Ev '(com|net|org|gov|mil|arpa)' 2>/dev/null

        tcpdump -nn -r "$fifo" -s 0 -v -n -l 2>/dev/null | egrep -i "POST /|GET /|Host:" 2>/dev/null

        tcpdump -nn -r "$fifo" -s 0 -A -n -l 2>/dev/null | egrep -i "POST /|pwd=|passwd=|password=|Host:" 2>/dev/null

        tcpdump -nn -r "$fifo" -s 0 -A -n -l 'port 23' 2>/dev/null | egrep -i "login:|password:" 2>/dev/null
    } > "$outfile"

    wait
    rm -f "$fifo"
}
export -f pure_func

for item in "$1"/*; do
    [ -f "$item" ] || continue
    logname="$2/$(basename "$item").log"
    pure_func "$item" "$logname" &
done

wait