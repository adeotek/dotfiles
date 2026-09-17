#!/bin/bash

###
# GCP CLI install script
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

# Install
case $CURRENT_OS_ID in
  arch)
    install_package "google-cloud-sdk" "gcloud --version"
    ;;
  debian|ubuntu|pop)
    if [[ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]]; then
      cecho "cyan" "Installing Google Cloud SDK APT source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        GCP_KEY_TMP="$(mktemp)"
        if curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg -o "$GCP_KEY_TMP" \
          && sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg "$GCP_KEY_TMP"; then
          echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
          sudo apt-get update
        else
          cecho "red" "Failed to install Google Cloud SDK APT key."
          return 1
        fi
        rm -f "$GCP_KEY_TMP"
      else
        cecho "yellow" "DRY-RUN: install Google Cloud SDK APT repository (keyring + sources entry + update)"
      fi
    fi
    install_package "google-cloud-cli" "gcloud --version"
    ;;
  fedora|redhat)
    # Google publishes yum repos for el7-el10 only — map the distro version
    # (Fedora has no versioned repos; map it to the current RHEL-compatible set)
    GC_ARCH="$CURRENT_ARCH"
    GC_EL_VERSION="${CURRENT_OS_VER%%.*}"
    if [[ "$CURRENT_OS_ID" == "fedora" ]]; then
      GC_EL_VERSION="10"
    fi
    GCP_GPG_KEY="https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg"
    if [[ "$GC_EL_VERSION" == "10" ]]; then
      GCP_GPG_KEY="https://packages.cloud.google.com/yum/doc/rpm-package-key-v10.gpg"
    fi
    # (Re)write the repo file when missing or pointing at an unsupported repo
    if [[ ! -f /etc/yum.repos.d/google-cloud-sdk.repo ]] \
      || ! grep -q "cloud-sdk-el${GC_EL_VERSION}-${GC_ARCH}" /etc/yum.repos.d/google-cloud-sdk.repo; then
      cecho "cyan" "Installing Google Cloud SDK YUM source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        decho "magenta" "tee /etc/yum.repos.d/google-cloud-sdk.repo << ..."
        sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el${GC_EL_VERSION}-${GC_ARCH}
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=${GCP_GPG_KEY}
EOM
      else
        cecho "yellow" "DRY-RUN: tee /etc/yum.repos.d/google-cloud-sdk.repo (cloud-sdk-el${GC_EL_VERSION}-${GC_ARCH})"
      fi
    fi
    # Prerequisite for the bundled Python runtime (see Google's install docs)
    install_package "libxcrypt-compat" "rpm -q libxcrypt-compat"
    install_package "google-cloud-cli" "gcloud --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
