#!/bin/bash
set -e  

error() {
    echo "Error: $1" >&2
    exit 1
}

if [ ! -d "benchmarks" ]; then
    git clone https://github.com/Geoka1/benchmarks.git || error "Failed to clone benchmarks repository"
fi

cd benchmarks
git switch feb || error "Failed to switch to branch 'feb'"

run_bare=false

for arg in "$@"; do
    if [ "$arg" == "--bare" ]; then
        run_bare=true
        break
    fi
done

if $run_bare; then
    bensh_dir="$(pwd)"

    echo "Running bensh on bare metal..."
    
    for benchmark in "$bensh_dir"/*; do
        if [ -d "$benchmark" ]; then
            benchmark_name=$(basename "$benchmark")

            if [[ "$benchmark_name" == "infrastructure" || "$benchmark_name" == "temp" ]]; then
                echo "Skipping $benchmark_name"
                continue
            fi

            echo "Running $benchmark_name"
            ./main.sh --min "$benchmark_name" || error "Failed to run $benchmark_name"
        fi
    done

    echo "Bensh execution complete."

else
    echo "Running bensh inside container..."
    docker run --cap-add NET_ADMIN --cap-add NET_RAW -it bensh ./benchmarks/main.sh --min || error "Bensh execution in container failed"
    echo "Bensh execution complete."
fi
