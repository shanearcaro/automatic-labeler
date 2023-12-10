#!/bin/sh -l

paths=$1
languages=$2

echo "Paths: ${paths}"
echo "Languages: ${languages}"

index=-1
for lang in ${languages}; do
  echo "$lang"
  if (( index > -1)); then
    echo "${lang[$index]}"
  fi
  ((index++))

done