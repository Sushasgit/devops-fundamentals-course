#!/bin/bash

for dir in "$@"; do
  if [ -d "$dir" ]
  then
    count=$(find "$dir" -type f | wc -l)
    echo "The directory $dir and it's subdirectories contain $count files."
  else
    echo "Error: $dir is not a directory."
  fi
done
