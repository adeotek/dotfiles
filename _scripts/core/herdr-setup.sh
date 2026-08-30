#!/bin/bash

###
# herdr setup script
# Stows only the herdr config file (herdr writes runtime files into ~/.config/herdr/)
# and installs shell completions for the current shell (zsh or bash).
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
source "$CDIR/herdr-install.sh"

# Setup — stow only the config file, not the whole package directory
symlink_package_file "herdr" ".config/herdr/config.toml"

# Shell completions
function setup_herdr_completions() {
  local current_shell
  current_shell="$(basename "$SHELL")"

  if ! command -v herdr >/dev/null 2>&1; then
    cecho "yellow" "Skipping [herdr] shell completions. [herdr] executable not found."
    return
  fi

  case "$current_shell" in
    zsh)
      if [[ "$DRY_RUN" -ne "1" ]]; then
        mkdir -p "$HOME/.zfunc"
        herdr completion zsh > "$HOME/.zfunc/_herdr"
        cecho "green" "[herdr] zsh completions generated at ~/.zfunc/_herdr"

        if [[ -f "$HOME/.zshrc.local" ]]; then
          if ! grep -q "# herdr completions" "$HOME/.zshrc.local"; then
            (
              echo ""
              echo "# herdr completions"
              echo "fpath=(~/.zfunc \$fpath)"
              echo "autoload -Uz _herdr && compdef _herdr herdr"
            ) >> "$HOME/.zshrc.local"
            cecho "green" "[herdr] zsh completion lines appended to ~/.zshrc.local"
          else
            cecho "yellow" "[herdr] zsh completion lines already present in ~/.zshrc.local"
          fi
        else
          printf '%s\n' "# herdr completions" "fpath=(~/.zfunc \$fpath)" "autoload -Uz _herdr && compdef _herdr herdr" > "$HOME/.zshrc.local"
          cecho "green" "[herdr] zsh completion lines written to ~/.zshrc.local"
        fi
      else
        cecho "yellow" "DRY-RUN: herdr completion zsh > ~/.zfunc/_herdr"
        cecho "yellow" "DRY-RUN: append [herdr] zsh completion lines to ~/.zshrc.local"
      fi
    ;;
    bash)
      if [[ "$DRY_RUN" -ne "1" ]]; then
        mkdir -p "$HOME/.local/share/bash-completion/completions"
        herdr completion bash > "$HOME/.local/share/bash-completion/completions/herdr"
        cecho "green" "[herdr] bash completions generated at ~/.local/share/bash-completion/completions/herdr"

        if [[ -f "$HOME/.bashrc.local" ]]; then
          if ! grep -q "# herdr completion" "$HOME/.bashrc.local"; then
            (
              echo ""
              echo "# herdr completion"
              echo "if [ -f \"\$HOME/.local/share/bash-completion/completions/herdr\" ]; then"
              echo "  source \"\$HOME/.local/share/bash-completion/completions/herdr\""
              echo "fi"
            ) >> "$HOME/.bashrc.local"
            cecho "green" "[herdr] bash completion lines appended to ~/.bashrc.local"
          else
            cecho "yellow" "[herdr] bash completion lines already present in ~/.bashrc.local"
          fi
        else
          printf '%s\n' "# herdr completion" "if [ -f \"\$HOME/.local/share/bash-completion/completions/herdr\" ]; then" "  source \"\$HOME/.local/share/bash-completion/completions/herdr\"" "fi" > "$HOME/.bashrc.local"
          cecho "green" "[herdr] bash completion lines written to ~/.bashrc.local"
        fi
      else
        cecho "yellow" "DRY-RUN: herdr completion bash > ~/.local/share/bash-completion/completions/herdr"
        cecho "yellow" "DRY-RUN: append [herdr] bash completion lines to ~/.bashrc.local"
      fi
    ;;
    *)
      cecho "yellow" "Shell [$current_shell] not supported. Skipping [herdr] shell completions."
    ;;
  esac
}

setup_herdr_completions
