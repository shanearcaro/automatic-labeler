#!/bin/sh

# Mark as safe directory
git config --global --add safe.directory $PWD

# Read in path and languages to traverse
paths=$1
languages=$2

# Define aliases
head=$GITHUB_HEAD_REF
base=$GITHUB_BASE_REF
git_event=$GITHUB_EVENT_NAME

# Define label prefix for local development
label_prefix=""
if [ -z $DEV_MODE ]; then
  label_prefix="origin/"
else
  label_prefix=""
fi

# Add a label to a pull request
add_label() {
  gh pr edit --add-label "$1"
  echo "Adding label $1"
}

# Search for a label
search_label() {
  label=$(echo $1 | xargs)
  search=$(gh label list -S $label)
  echo $search
}

# Create a label
create_label() {
  # Remove trailing whitespace
  label=$(echo $1 | xargs)
  gh label create "$label" -d "Label automatically created by shanearcaro/organize-pr"
}

# Check if a label exists, if not create it
check_label() {
  label=$(echo $1 | xargs)
  search=$(search_label "$label")
  if [ -z "$search" ]; then
    echo "Creating label: $label"
    create_label "$label"
  else
    echo "Label exists: $search"
  fi
}

# Get changed files from the pull request
get_changed_files() {
  changed_files=$(git diff --name-only $label_prefix"$head" $label_prefix"$base")
  echo $changed_files
}

# Get unique file extensions from changed files
get_changed_file_ext() {
  changed_files=$(get_changed_files)
  extensions=""
  for file in $changed_files; do
    # Extract file extensions
    file_ext="${file##*.}"
    extensions="$extensions $file_ext"
  done
  
  # Remove duplicate extensions, need to convert spaces to new lines then back again
  extensions=$(echo $extensions | tr ' ' '\n' | sort -u | tr '\n' ' ')
  echo $extensions
}

# Get unique file paths from changed files
get_changed_file_paths() {
  changed_files=$(get_changed_files)
  changed_paths=""
  for file in $changed_files; do
    # Extract file paths
    file_path=$(dirname "$file")
    changed_paths="$changed_paths $file_path"
  done
  
  # Remove duplicate paths, need to convert spaces to new lines then back again
  changed_paths=$(echo $changed_paths | tr ' ' '\n' | sort -u | tr '\n' ' ')
  echo $changed_paths
}

# Add language labels to an event
add_language_labels() {
  extensions=$(get_changed_file_ext)
  for ext in $extensions; do
    # Check if file extension is in languages
    match=$(echo "$languages" | grep "$ext" | awk '{print $2}' | xargs)
    if [ -n "$match" ]; then
      # Get label
      echo "Match: $match"
      check_label "$match"
      add_label "$match"
    fi
  done
}

add_paths_labels() {
  changed_paths=$(get_changed_file_paths)
  for path in $changed_paths; do
    # Check if file path is in paths (match using : as suffix to avoid matching subdirectories)
    match=$(echo "$paths" | grep -w "$path:" | awk '{print $2}' | xargs)
    if [ -n "$match" ]; then
      echo "Match: $match"
      check_label "$match"
      add_label "$match"
    fi
  done
}

# Need to checkout branch before using git commands
git checkout "$head"

echo "Running comparison on "$head" and "$base""
echo "Changed files: $(get_changed_files)"
echo "Changed paths: $(get_changed_file_paths)"
echo "Changed extensions: $(get_changed_file_ext)"

add_language_labels
add_paths_labels

