#!/bin/bash

for file in "$@"; do
  # pandoc -f gfm -t gfm --wrap=auto --columns=80 "$file" -o "${file}.tmp" && mv "${file}.tmp" "$file"
  npx prettier --prose-wrap always --print-width 80 --write "$file"
done
