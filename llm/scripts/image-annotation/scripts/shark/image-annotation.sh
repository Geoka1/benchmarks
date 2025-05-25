#!/bin/bash
REPO_TOP=$(git rev-parse --show-toplevel)
eval_dir="$REPO_TOP/llm/scripts/image_annotation"
input_dir="$eval_dir/inputs"
outputs_dir="$eval_dir/outputs"

IN=${1:-"$input_dir"}
OUT=${2:-"$outputs_dir"}
mkdir -p "$OUT"

current_jobs=0
MAX_PROCS=${MAX_PROCS:-$(nproc)}

process_image() {
    img="$1"

    title=$(llm -m gemma3 \
        "Your only output should be a **single** small title for this image:" \
        -a "$img" -o seed 0 -o temperature 0 < /dev/null)

    base=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g; s/[^a-z0-9_-]//g')
    filename="${base}.jpg"
    count=1

    {
        flock -n 200 || exit 1
        while [ -e "$OUT/$filename" ]; do
            filename="${base}_$count.jpg"
            count=$((count + 1))
        done
        cp "$img" "$OUT/$filename"
    } 200>"$OUT/.lock"
}

export OUT
export -f process_image

while IFS= read -r img; do
    process_image "$img" &

    ((current_jobs++))
    if (( current_jobs >= MAX_PROCS )); then
        wait -n
        ((current_jobs--))
    fi
done < <(find "$IN" -type f -iname "*.jpg")

wait