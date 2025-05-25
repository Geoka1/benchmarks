#!/bin/bash
# source: posh benchmark suite

input="$1"
dest="$2"

#mogrify  -format gif -path "$dest" -thumbnail 100x100 $input/*.jpg

export dest

find "$input" -name '*.jpg' | parallel \
  'mogrify -format gif -path "$dest" -thumbnail 100x100 "{}"'