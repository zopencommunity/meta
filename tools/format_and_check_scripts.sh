#!/bin/sh

format=false
shellcheck=false
verbose=false

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

if [ "$format" = false ] && [ "$shellcheck" = false ]; then
  echo "Usage: $0 [-f | --format] [-s | --shellcheck] [-v | --verbose] [file1.sh file2.sh ...]"
  exit 1
fi

if [ "$format" = true ]; then
  for file in $files; do
    if [ "$verbose" = true ]; then
      echo "Formatting $file..."
    fi
    shfmt -i 2 -fn -sr -w "$file"
  done
fi

if [ "$shellcheck" = true ]; then
  for file in $files; do
    if [ "$verbose" = true ]; then
      echo "Running ShellCheck on $file..."
    fi
    shellcheck --shell sh -f diff -o all -e SC2268,SC2086 "$file" | git apply
  done
fi
