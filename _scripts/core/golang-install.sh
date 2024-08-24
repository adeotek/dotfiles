#!/bin/bash

###
# Go Lang install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
cecho "yellow" "WARNING: Go Lang install not implemented yet!"

## ARCH
# # Install Go
# sudo dnf install -y golang
# mkdir -p $HOME/go
# echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
# source $HOME/.bashrc