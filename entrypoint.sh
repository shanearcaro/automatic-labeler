#!/bin/sh

# Mark as safe directory
git config --global --add safe.directory $PWD

# Read in path and languages to traverse
paths=$1
languages=$2
event_type=$3
head_ref=$4

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

# Search for a label
search_label() {
  search=$(gh label list -S "$1")
  echo "$search"
}

create_label() {
  # Remove trailing whitespace
  label=$(echo $1 | xargs)
  gh label create $label -d "Label automatically created by shanearcaro/organize-pr"
}

is_label() {
  if echo "$1" | grep -q ':$'; then
    return ${item%:*}
  else
    return $1
  fi
}

gh pr checkout $head_ref
extension=""
for item in $languages; do
  # Check if item has a trailing colon
  if echo "$item" | grep -q ':$'; then
    # Remove trailing colon
    extension=${item%:*}
  else
    echo "Label: $item Extension: $extension"
    echo "Searching for label: $item"
    if [ -z "$(search_label "$item")" ]; then
      echo "Label not found, creating label"
      create_label "$item"
    else
      echo "Label found, adding label"
      add_labels "$item"
    fi
   
  fi
done
