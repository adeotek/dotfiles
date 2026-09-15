#!/bin/bash

###
# Ansible cleanup script
# Removes old deb/rpm Ansible and Ansible Lint installations
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

cecho "cyan" "Cleaning up old [ansible] package manager installations..."

cleanup_done=0

case $CURRENT_OS_ID in
  arch)
    installed_pkgs=()
    for p in ansible ansible-lint; do
      if pacman -Qi "$p" >/dev/null 2>&1; then
        installed_pkgs+=("$p")
      fi
    done
    if [[ "${#installed_pkgs[@]}" -gt 0 ]]; then
      if [[ "$DRY_RUN" -ne "1" ]]; then
        if sudo pacman -Rns --noconfirm "${installed_pkgs[@]}"; then
          cecho "green" "Removed ${installed_pkgs[*]} via pacman."
        else
          cecho "red" "Failed to remove ${installed_pkgs[*]} via pacman."
        fi
      else
        cecho "yellow" "DRY-RUN: sudo pacman -Rns --noconfirm ${installed_pkgs[*]}"
      fi
      cleanup_done=1
    else
      decho "yellow" "ansible not installed via pacman — skipping."
    fi
  ;;
  debian|ubuntu|pop)
    apt_cleanup_needed=0
    installed_pkgs=()
    for p in ansible ansible-lint; do
      if dpkg -s "$p" >/dev/null 2>&1; then
        installed_pkgs+=("$p")
      fi
    done

    if [[ "${#installed_pkgs[@]}" -gt 0 ]]; then
      apt_cleanup_needed=1
    fi

    if [[ -f /etc/apt/sources.list.d/ansible.list ]] || [[ -f /usr/share/keyrings/ansible-archive-keyring.gpg ]]; then
      apt_cleanup_needed=1
    fi

    if grep -rq "^deb.*ansible/ansible" /etc/apt/sources.list.d/ 2>/dev/null; then
      apt_cleanup_needed=1
    fi

    if [[ "$apt_cleanup_needed" -eq "1" ]]; then
      if [[ "$DRY_RUN" -ne "1" ]]; then
        if [[ "${#installed_pkgs[@]}" -gt 0 ]]; then
          if sudo apt-get remove -y "${installed_pkgs[@]}"; then
            cecho "green" "Removed ${installed_pkgs[*]} via apt-get."
          else
            cecho "red" "Failed to remove ${installed_pkgs[*]} via apt-get."
          fi
        fi
        sudo apt-get autoremove -y 2>/dev/null || true

        if [[ -f /etc/apt/sources.list.d/ansible.list ]]; then
          sudo rm -f /etc/apt/sources.list.d/ansible.list
          cecho "green" "Removed /etc/apt/sources.list.d/ansible.list"
        fi

        if [[ -f /usr/share/keyrings/ansible-archive-keyring.gpg ]]; then
          sudo rm -f /usr/share/keyrings/ansible-archive-keyring.gpg
          cecho "green" "Removed /usr/share/keyrings/ansible-archive-keyring.gpg"
        fi

        for f in /etc/apt/sources.list.d/*ansible*; do
          if [[ -f "$f" ]]; then
            sudo rm -f "$f"
            cecho "green" "Removed $f"
          fi
        done

        sudo apt-get update 2>/dev/null || true
        decho "green" "Old ansible packages and repos cleanup finished."
      else
        if [[ "${#installed_pkgs[@]}" -gt 0 ]]; then
          cecho "yellow" "DRY-RUN: sudo apt-get remove -y ${installed_pkgs[*]}"
        fi
        cecho "yellow" "DRY-RUN: sudo apt-get autoremove -y"
        cecho "yellow" "DRY-RUN: rm /etc/apt/sources.list.d/ansible.list"
        cecho "yellow" "DRY-RUN: rm /usr/share/keyrings/ansible-archive-keyring.gpg"
        cecho "yellow" "DRY-RUN: rm /etc/apt/sources.list.d/*ansible*"
        cecho "yellow" "DRY-RUN: sudo apt-get update"
      fi
      cleanup_done=1
    else
      decho "yellow" "No old ansible packages or repos found — skipping."
    fi
  ;;
  fedora|redhat)
    installed_pkgs=()
    for p in ansible ansible-lint; do
      if rpm -q "$p" >/dev/null 2>&1; then
        installed_pkgs+=("$p")
      fi
    done
    if [[ "${#installed_pkgs[@]}" -gt 0 ]]; then
      if [[ "$DRY_RUN" -ne "1" ]]; then
        if sudo dnf remove -y "${installed_pkgs[@]}"; then
          cecho "green" "Removed ${installed_pkgs[*]} via dnf."
        else
          cecho "red" "Failed to remove ${installed_pkgs[*]} via dnf."
        fi
        sudo dnf autoremove -y 2>/dev/null || true
      else
        cecho "yellow" "DRY-RUN: sudo dnf remove -y ${installed_pkgs[*]}"
        cecho "yellow" "DRY-RUN: sudo dnf autoremove -y"
      fi
      cleanup_done=1
    else
      decho "yellow" "ansible not installed via dnf — skipping."
    fi
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac

if [[ "$cleanup_done" -eq "0" ]]; then
  cecho "yellow" "Nothing to clean up."
else
  cecho "green" "[ansible] cleanup complete."
fi
