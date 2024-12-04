alias dc="docker compose"

u() {
  git add --all && git commit --amend --no-edit --no-verify
}

awip() {
  git add --all && git commit --amend --no-edit --no-verify && git push origin HEAD:refs/for/master%wip
}

a() {
  git add --all && git commit --amend --no-edit --no-verify && git push origin HEAD:refs/for/master
}

p() {
  git push origin HEAD:refs/for/master
}

j() {
  yarn run test:jest:watch
}

function b() {
    local branches branch
    branches=$(git for-each-ref --sort=-committerdate refs/heads/ --format="%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:blue)%(contents:subject)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) [%(color:red)%(authorname)%(color:reset)]") \
    && branch=$(echo "$branches" | fzf --ansi --no-sort) \
    && branch=$(echo "$branch" | awk '{print $1}' | sed 's/\* //') \
    && git checkout "$branch"
}

function delb() {
    local branches branch
    branches=$(git for-each-ref --sort=-committerdate refs/heads/ --format="%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:blue)%(contents:subject)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) [%(color:red)%(authorname)%(color:reset)]") \
    && branch=$(echo "$branches" | fzf --ansi --no-sort) \
    && branch=$(echo "$branch" | awk '{print $1}' | sed 's/\* //') \
    && [[ "$branch" != "master" ]] && git branch -D "$branch" || echo "Cannot delete master branch"
}

function whodoes() { git log --since="3 months ago" --pretty="%an" -- "$1" | sort | uniq -c | sort -rn; }

function recent() {
  git diff --name-only HEAD~1 | xargs code
}

function local_yarn() {
  mv gems/plugins ~/tmp && yarn install; mv ~/tmp/plugins gems/
}

function docker_yarn() {
  mv gems/plugins ~/tmp && docker-compose exec web yarn; mv ~/tmp/plugins gems/
}

copy_dir_contents_to_clipboard() {
  # Check if exactly one argument is provided
  if [[ $# -ne 1 ]]; then
    echo "Usage: copy_dir_contents_to_clipboard <directory_path>"
    return 1
  fi

  local dir="$1"

  # Check if the provided argument is a directory
  if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' is not a directory or does not exist."
    return 1
  fi

  # Initialize a temporary file to store the aggregated content
  local temp_file
  temp_file=$(mktemp)

  # Use find to traverse the directory recursively and filter for text files
  find "$dir" -type f | while IFS= read -r file; do
    # Check if the file is a text file
    if file "$file" | grep -q "text"; then
      # Get the relative path of the file for cleaner output
      relative_path="${file#$dir/}"

      # Append the header and file contents to the temporary file
      {
        echo "This is ${relative_path}"
        echo
        echo '```'
        cat "$file" 2>/dev/null || echo "Error reading file: $file"
        echo '```'
        echo
      } >> "$temp_file"
    else
      echo "Skipping binary file: $file" >&2
    fi
  done

  # Copy the aggregated content to the clipboard
  pbcopy < "$temp_file"

  # Remove the temporary file
  rm "$temp_file"

  echo "Contents of all text files in '$dir' have been copied to the clipboard."
}

function quick() {
  git add --all
  git commit -m "$1"
  git push
}
