#!/bin/sh -l

paths=$1
languages=$2

echo "Paths: ${paths}"
echo "Languages: ${languages}"

for lang in languages; do
  echo "$lang"
done