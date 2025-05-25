#!/bin/bash
# tag: segment-classify-index sequential
# inputs: $1=absolute source image dir, $2=output file path

IMG_DIR="$1"
OUT="$2"
MAX_PROCS="${MAX_PROCS:-$(nproc)}"

# Limit thread count for determinism
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

process_image() {
    img="$1"
    fifo=$(mktemp -u)
    mkfifo "$fifo"

    python3 scripts/sam_segment.py < "$img" > "$fifo" &

    python3 scripts/classify.py "$img" < "$fifo" | while read -r line; do
        echo "\"$(basename "$img")\" $line"
    done

    rm "$fifo"
}
export -f process_image

job_count=0

for img in "$IMG_DIR"/*.png; do
    process_image "$img" >> "$OUT" &
    ((++job_count))

    if (( job_count >= MAX_PROCS )); then
        wait -n
        ((--job_count))
    fi
done

wait 