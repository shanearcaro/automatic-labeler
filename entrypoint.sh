#!/bin/sh

# Mark as safe directory
git config --global --add safe.directory $PWD

# Read in path and languages to traverse
paths=$1
languages=$2

head=$GITHUB_HEAD_REF
base=$GITHUB_BASE_REF
event=$INPUT_EVENT

echo "Head: ${head}"
echo "Base: ${base}"
echo "Event: ${event}"

echo "Paths: ${paths} \n"
echo "Languages: ${languages} \n"

# Add labels to events
add_labels() {
  if [ $event = "pull_request" ]; then
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
  gh label create "$label" -d "Label automatically created by shanearcaro/organize-pr"
}

add_pr_labels() {
  files=$(git diff --name-only "$head" "$base")
  tags_added=""

  for file in $files; do
    # Extract file extension5
    file_ext="${file##*.}"

    # Check if file extension is in languages
    found_ext=$(echo "$languages" | grep -o "$file_ext")
    if [ -n "$found_ext" ]; then
      if [ -z $(echo "$tags_added" | grep -o "$file_ext") ]; then
        add_labels
        tags_added="$tags_added $file_ext"
        echo "$file_ext tag added"
      else
        echo "$file_ext tag already added"
      fi
    fi
  done
}

# Need to checkout branch before using git commands
gh pr checkout "$head"

add_pr_labels


# extension=""
# for item in $languages; do
#   # Check if item has a trailing colon
#   if echo "$item" | grep -q ':$'; then
#     # Remove trailing colon
#     extension=${item%:*}
#   else
#     echo "Label: $item Extension: $extension"
#     echo "Searching for label: $item"
#     if [ -z "$(search_label "$item")" ]; then
#       echo "Label not found, creating label"
#       create_label "$item"
#     else
#       echo "Label found, adding label"
#       add_labels "$item"
#     fi
#   fi
# done
