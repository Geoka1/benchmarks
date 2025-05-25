# file: files.jsonl   ←– your lines go in here
awk '
  # Extract the text inside "category": "…"
  {
    match($0, /"category"[[:space:]]*:[[:space:]]*"([^"]+)"/, m)
    cat = m[1]              # the category itself
    print cat "\t" $0       # prepend it as a sortable key
  }
' a.jsonl \
| sort -k1,1 \
| cut -f2- > a.sorted

