#!/bin/sh

format=false
shellcheck=false
verbose=false

# Parse command line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -f | --format)
      format=true
      ;;
    -s | --shellcheck)
      shellcheck=true
      ;;
    -v | --verbose)
      verbose=true
      ;;
    *)
      if [ -f "$1" ]; then
        files="$files $1"
      else
        echo "Ignoring invalid file: $1"
      fi
      ;;
  esac
  shift
done

# Check if either format or shellcheck option is specified
if [ "$format" = false ] && [ "$shellcheck" = false ]; then
  echo "Usage: $0 [-f | --format] [-s | --shellcheck] [-v | --verbose] [file1.sh file2.sh ...]"
  exit 1
fi

# Run shfmt if the format option is specified
if [ "$format" = true ]; then
  for file in $files; do
    if [ "$verbose" = true ]; then
      echo "Formatting $file..."
    fi
    shfmt -i 2 -fn -w "$file"
  done
fi

# Run shellcheck if the shellcheck option is specified
if [ "$shellcheck" = true ]; then
  for file in $files; do
    if [ "$verbose" = true ]; then
      echo "Running ShellCheck on $file..."
    fi
    shellcheck -f diff -s sh -o all "$file"
  done
fi
