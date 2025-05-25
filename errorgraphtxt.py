import os
import re
import csv
from collections import defaultdict
from statistics import mean

# Regex patterns to extract metrics
patterns = {
    "Total_CPU_time": re.compile(r"^Total CPU time:\s+([\d.]+)"),
    "Total_Wall_time": re.compile(r"^Total Wall time:\s+([\d.]+)"),
    "Total_IO_bytes": re.compile(r"^Total IO bytes:\s+([\d.]+)"),
    "Max_Memory_Usage": re.compile(r"^Max Memory Usage:\s+([\d.]+)"),
    "CPU_time_per_byte": re.compile(r"^CPU time per input byte:\s+([\d.]+)"),
    "Memory_per_byte": re.compile(r"^Memory per input byte:\s+([\d.]+)"),
    "IO_per_byte": re.compile(r"^IO per input byte:\s+([\d.]+)"),
    "Time_in_Shell": re.compile(r"^Time in Shell:\s+([\d.]+)"),
    "Time_in_Commands": re.compile(r"^Time in Commands:\s+([\d.]+)")
}

# Walk subdirectories
for root, dirs, files in os.walk("."):
    stat_files = [f for f in files if f.endswith(".txt") and "_bash_stats_run" in f]
    if not stat_files:
        continue

    stats = defaultdict(list)

    for filename in stat_files:
        path = os.path.join(root, filename)
        with open(path, "r") as f:
            for line in f:
                for key, pattern in patterns.items():
                    match = pattern.match(line)
                    if match:
                        stats[key].append(float(match.group(1)))

    if not stats:
        continue

    # Prepare CSV output
    csv_path = os.path.join(root, "summary_stats.csv")
    with open(csv_path, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Metric", "Mean", "Min", "Max"])
        for key in sorted(stats):
            values = stats[key]
            writer.writerow([key, f"{mean(values):.6f}", f"{min(values):.6f}", f"{max(values):.6f}"])

    print(f"Processed: {root}")

