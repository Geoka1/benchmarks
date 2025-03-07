#!/bin/bash

# Exit immediately if a command exits with a non-zero status
# set -e

cd "$(realpath $(dirname "$0"))"
mkdir -p hashes/small

[ ! -d "outputs" ] && echo "Directory 'outputs' does not exist" && exit 1

if [[ "$@" == *"--small"* ]]; then
    hash_folder="hashes/small"
else
    hash_folder="hashes"
fi

if [[ "$@" == *"--generate"* ]]; then
    # Directory to iterate over
    directory="outputs"

    # Loop through all .out files in the directory
    for file in "$directory"/*.out
    do
        # Extract the filename without the directory path and extension
        filename=$(basename "$file" .out)

        # Generate SHA-256 hash
        hash=$(shasum -a 256 "$file" | awk '{ print $1 }')

        # Save the hash to a file
        echo "$hash" > "$hash_folder/$filename.hash"

        # Print the filename and hash
        echo "$hash_folder/$filename.hash $hash"
    done

    exit 0
fi

# Loop through all directories in the parent directory
for folder in "outputs"/
do
    # Remove trailing slash
    folder=${folder%/}

    # Loop through all .out files in the current directory
    for file in "$folder"/*.out
    do
        # Extract the filename without the directory path and extension
        filename=$(basename "$file" .out)

        # Generate SHA-256 hash
        hash=$(shasum -a 256 "$file" | awk '{ print $1 }')

        # Save the hash to a file
        echo "$hash" > "$folder/$filename.hash"

        diff "$hash_folder/$filename.hash" "$folder/$filename.hash" > /dev/null
        match="$?"
        # Print the filename and hash
        echo "$folder/$filename $match"
    done
done
