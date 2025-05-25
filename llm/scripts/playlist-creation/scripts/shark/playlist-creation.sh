#!/bin/bash

REPO_TOP=$(git rev-parse --show-toplevel)
eval_dir="$REPO_TOP/llm/scripts/playlist-creation"
input_dir=$REPO_TOP/llm/inputs/scripts/playlist-creation/inputs
outputs_dir=$eval_dir/outputs

IN=${1:-"$input_dir"}
OUT="${2:-"$outputs_dir"}"
mkdir -p "$OUT"
MAX_PROCS=${MAX_PROCS:-$(nproc)}

# files=$(find "$IN" -type f \( -iname "*.mp3" -o -iname "*.wav" \) | sort)
# num_files=$(printf '%s\n' "$files" | wc -l)

current_jobs=0

process_directory() {
    dir_path="$1"
    OUT="$2"

    [ -d "$dir_path" ] || exit 0
    dir=$(basename "$dir_path")
    echo "Processing directory: $dir"

    files=$(find "$dir_path" -type f -name "*.mp3" | sort)
    num_files=$(printf '%s\n' "$files" | wc -l)
    [ "$num_files" -eq 0 ] && echo "No mp3 files in $dir" && exit 0

    abs_prefix=$(realpath "$dir_path")
    llm embed-multi -m clap songs --binary --files "$abs_prefix" '*.mp3' --prefix "$abs_prefix/"

    first_song=$(printf '%s\n' "$files" | head -n 1)
    last_song=$(printf '%s\n' "$files" | tail -n 1)

    mkdir -p "$OUT/$dir"
    playlist_path="$OUT/$dir/playlist.m3u"

    llm interpolate songs "$first_song" "$last_song" -n "$num_files" | jq .[] > "$playlist_path"
}

for dir_path in "$IN"/*; do
    [ -d "$dir_path" ] || continue

    process_directory "$dir_path" "$OUT" &

    ((current_jobs++))
    if (( current_jobs >= MAX_PROCS )); then
        wait -n
        ((current_jobs--))
    fi
done

wait 