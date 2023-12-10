#!/bin/sh

paths=$1
languages=$2

echo "Paths: ${paths}"
echo "Languages: ${languages}"

index=-1
for lang in ${languages}; do
  echo "$lang"
  if [ $index -gt -1 ]; then
    echo "${languages[$index]}"
  fi
  index=$((index + 1))
done
