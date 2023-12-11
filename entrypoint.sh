#!/bin/sh

# Mark as safe directory
git config --global --add safe.directory $PWD

# Read in path and languages to traverse
paths=$1
languages=$2

# Define aliases
head=$GITHUB_HEAD_REF
base=$GITHUB_BASE_REF
git_event=$INPUT_EVENT

echo "Head: ${head}"
echo "Base: ${base}"
echo "Event: ${git_event}"

echo "Paths: ${paths} \n"
echo "Languages: ${languages} \n"

# Add labels to events
add_labels() {
  echo "Value $1"
  if [ $git_event = "pull_request" ]; then
    gh pr edit --add-label "$1"
  else
    gh issue edit --add-label "$1"
  fi
}

# Search for a label
search_label() {
  label=$(echo $1 | xargs)
  search=$(gh label list -S $label)
  echo $search
}

create_label() {
  # Remove trailing whitespace
  label=$(echo $1 | xargs)
  gh label create "$label" -d "Label automatically created by shanearcaro/organize-pr"
}

add_pr_labels() {
  tags_added=""
  echo "Is this working: $1"

  for file in $1; do
    # Extract file extensions
    file_ext="${file##*.}"

    # Check if file extension is in languages
    found_ext=$(echo "$languages" | grep -o "$file_ext")
    if [ -n "$found_ext" ]; then
      if [ -z $(echo "$tags_added" | grep -o "$file_ext") ]; then
        add_labels $2
        echo "$2 tag added"
      else
        echo "$2 tag already added"
      fi
    fi
  done
}

get_changed_files() {
  changed_files=""
  if [ $git_event = "pull_request" ]; then
    changed_files=$(git diff --name-only "$head" "$base")
  else
    changed_files=$(git diff --name-only "$head")
  fi
  echo $changed_files
}

generate_labels() {
  changed_files=$(get_changed_files)
  echo "Changed files: $changed_files"
  extensions=""

  for item in $languages; do
    # Check if item has a trailing colon
    if echo "$item" | grep -q ':$'; then
      # Remove trailing colon
      extension=${item%:*}
    else
      echo "Label: $item Extension: $extension"
      search_result=$(search_label $item)
      if [ -z "$search_result" ]; then
        echo "Label not found, creating label"
        create_label "$item"
      else
        echo "Label found, adding label"
        add_pr_labels "$changed_files" "$item"
      fi
    fi
  done
}

# Need to checkout branch before using git commands
gh pr checkout "$head"
generate_labels

