#!/bin/sh

# Read in path and languages to traverse
paths=$1
languages=$2
event_type=$3

echo "Paths: ${paths} \n"
echo "Languages: ${languages} \n"

# Add labels to events
add_labels() {
  if [ "$event_type" = "pull_request" ]; then
    gh pr edit --add-label "$1"
  else
    gh issue edit --add-label "$1"
  fi
}

extension=""
for item in $languages; do
  # Check if item has a trailing colon
  if echo "$item" | grep -q ':$'; then
    # Remove trailing colon
    extension=${item%:*}
  else
    echo "Label: $item Extension: $extension"
    add_labels "$item"
  fi
done
