#!/bin/bash

VV="0"
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VV="1"
    ;;
    --*)
      if [[ ! -v ARGS[${1:2}] ]]; then
        echo "ERROR[2]: Invalid argument/flag: $1!"
        exit 2
      fi
      if [[ -z "$2" || "${2:0:2}" == "--" ]]; then
        ARGS[${1:2}]=1
      else
        ARGS[${1:2}]=$2
        shift
      fi
    ;;
    *)
      echo "ERROR[0]: Unknown argument/flag: $1!"
      exit 2
    ;;
  esac
  shift
done

secho() {
  local message="$1"
  if [[ "$VV" -eq "1" ]]; then
    echo $message
  fi
}

get_vv() {
  if [[ "$VV" -eq "1" ]]; then
    echo "-v"
  else
    echo ""
  fi
}

rename_dir_if_exists() {
  local target="$1"
  local suffix="$2"

  if [ -d "$target" ]; then
    mv "$target" "$target$suffix"
    secho "Directory found and renamed to [$target$suffix]"
  else
    secho "Directory [$target] not found!"
  fi
}
