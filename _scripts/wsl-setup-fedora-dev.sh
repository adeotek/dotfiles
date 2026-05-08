#!/bin/bash

##
# Fedora WSL setup script
##

# Prerequisites:
# - Install Fedora WSL distro: wsl install FedoraLinux-<ver>
# - Set a password for the default user: wsl -d FedoraLinux-<ver> -- sudo passwd $USER

# Post-configuration:
# - Authenticate GitHub CLI: gh auth login
# - Authenticate Claude Code CLI: claude auth login

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Sets up a Fedora WSL development environment by installing dotfiles packages,
configuring Git, copying SSH keys, and optionally installing extra tools.

OPTIONS:
  --win-user <name>       Windows username (used to locate SSH keys at /mnt/c/Users/<name>/.ssh)
  --custom-ca-src <path>  Directory containing *.crt files to add to the system trust store
  --git-name <name>       Git user.name for ~/.config/git.user/config
  --git-email <email>     Git user.email for ~/.config/git.user/config
  --nx-version <ver>      Install NX globally at the specified version (e.g. 19.0.0)
  --angular-version <ver> Install Angular CLI globally at the specified version (e.g. 18.0.0) 
  --ansible               Enable Ansible installation (default: off)
  --claude                Enable Claude Code installation    (default: off)
  --docker                Enable Docker installation  (default: off)
  --golang                Enable Golang installation  (default: off)
  --kubectl               Enable Kubectl and Helm installation (default: off)
  --rust                  Enable Rust installation    (default: off)
  --terraform             Enable Terraform installation (default: off)
  -h, --help              Show this help message and exit

EXAMPLES:
  $(basename "$0") --win-user john --git-name "John Doe" --git-email john@example.com
  $(basename "$0") --terraform --rust --nx-version 19.0.0
  # Full setup with all options enabled:
  $(basename "$0") --win-user john \\
    --custom-ca-src /mnt/c/certs \\
    --git-name "John Doe" \\
    --git-email "john.doe@domain.com" \\
    --nx-version 19.0.0 \\
    --angular-version 18.0.0 \\
    --ansible \\
    --claude \\
    --docker \\
    --golang \\
    --kubectl \\
    --rust \\
    --terraform
EOF
}

# Input arguments (defaults)
WINDOWS_USERNAME=""
CUSTOM_CA_SRC_PATH=""
GIT_USER_NAME=""
GIT_USER_EMAIL=""
NX_VERSION=""
ANGULAR_VERSION=""
INSTALL_ANSIBLE=false
INSTALL_CLAUDECODE=false
INSTALL_DOCKER=false
INSTALL_GOLANG=false
INSTALL_KUBECTL=false
INSTALL_RUST=false
INSTALL_TERRAFORM=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --win-user)         WINDOWS_USERNAME="$2";     shift 2 ;;
    --custom-ca-src)    CUSTOM_CA_SRC_PATH="$2";   shift 2 ;;
    --git-name)         GIT_USER_NAME="$2";        shift 2 ;;
    --git-email)        GIT_USER_EMAIL="$2";       shift 2 ;;
    --nx-version)       NX_VERSION="$2";           shift 2 ;;
    --angular-version)  ANGULAR_VERSION="$2";      shift 2 ;;
    --ansible)          INSTALL_ANSIBLE=true;      shift ;;
    --claude)           INSTALL_CLAUDECODE=true;   shift ;;
    --docker)           INSTALL_DOCKER=true;       shift ;;
    --golang)           INSTALL_GOLANG=true;       shift ;;
    --kubectl)          INSTALL_KUBECTL=true;      shift ;;
    --rust)             INSTALL_RUST=true;         shift ;;
    --terraform)        INSTALL_TERRAFORM=true;    shift ;;
    -h|--help)          usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
done

stage_status() {
  if [ "$1" = true ]; then
    echo -e "\e[36m[DONE]    $2\e[0m"
  else
    echo -e "\e[35m[SKIPPED] $2\e[0m"
  fi
}
echo_warning() {
  echo -e "\e[33m[WARNING] $1\e[0m"
}
echo_error() {
  echo -e "\e[31m[ERROR]   $1\e[0m"
  exit 1
}

# Configuration variables
SSH_KEY_SRC_PATH="/mnt/c/Users/${WINDOWS_USERNAME}/.ssh"
CUSTOM_CA_DEST_PATH="/etc/pki/ca-trust/source/anchors"
DOTFILES_CLONE_URL="https://github.com/adeotek/dotfiles.git"

declare DOTFILES_PACKAGES=(
  "base-tools"
  "bash"
  "dotnet"
  "fastfetch"
  "gcp-cli"
  "git"
  "github-cli"
  "glow"
  "nodejs"
  "onefetch"
  "powershell"
  "tmux"
  "tools"
  "uv"
  "yazi"
  "zsh"
)

# --- WSL configuration ---

_changed=false
_WSL_CONF="/etc/wsl.conf"
if ! grep -q "appendWindowsPath" "$_WSL_CONF" 2>/dev/null; then
  if grep -q "\[interop\]" "$_WSL_CONF" 2>/dev/null; then
    sudo sed -i '/^\[interop\]/a appendWindowsPath = false' "$_WSL_CONF"
  else
    sudo tee -a "$_WSL_CONF" > /dev/null <<'EOF'

[interop]
appendWindowsPath = false
EOF
  fi
  _changed=true
fi
stage_status $_changed "WSL configuration (/etc/wsl.conf)"

# appendWindowsPath only takes effect on distro restart, but we can strip
# Windows-mounted paths from the current session immediately.
if echo "$PATH" | grep -q '/mnt/[a-z]/'; then
  export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '^/mnt/[a-z]/' | tr '\n' ':' | sed 's/:$//')
  stage_status true "Windows paths removed from current session PATH"
else
  stage_status false "Windows paths removed from current session PATH"
fi

# --- Install base tools ---

sudo dnf install -y nano curl wget mc jq git awk openssl ca-certificates
stage_status true "Base tools installed"

# --- SSH Keys ---

_changed=false
if [ -n "${WINDOWS_USERNAME}" ]; then
  if [ ! -d "${SSH_KEY_SRC_PATH}" ]; then
    echo_warning "Windows username provided (${WINDOWS_USERNAME}), but SSH key source path does not exist: ${SSH_KEY_SRC_PATH}."
  else
    mkdir -p ~/.ssh
    if [ ! -f ~/.ssh/id_rsa ] && [ -f "${SSH_KEY_SRC_PATH}/id_rsa" ]; then
      cp "${SSH_KEY_SRC_PATH}/id_rsa" ~/.ssh/id_rsa
      chmod 600 ~/.ssh/id_rsa
      _changed=true
    fi
    if [ ! -f ~/.ssh/id_rsa.pub ] && [ -f "${SSH_KEY_SRC_PATH}/id_rsa.pub" ]; then
      cp "${SSH_KEY_SRC_PATH}/id_rsa.pub" ~/.ssh/id_rsa.pub
      chmod 644 ~/.ssh/id_rsa.pub
      _changed=true
    fi
    if [ ! -f ~/.ssh/known_hosts ] && [ -f "${SSH_KEY_SRC_PATH}/wsl_known_hosts" ]; then
      cp "${SSH_KEY_SRC_PATH}/wsl_known_hosts" ~/.ssh/known_hosts
      chmod 600 ~/.ssh/known_hosts
      _changed=true
    fi
  fi
fi
stage_status $_changed "SSH keys"

# --- Custom CA certificates ---

_changed=false
if [ -n "${CUSTOM_CA_SRC_PATH}" ]; then
  if [ ! -d "${CUSTOM_CA_SRC_PATH}" ]; then
    echo_warning "Custom CA source path does not exist: ${CUSTOM_CA_SRC_PATH}."
  else
    sudo mkdir -p "${CUSTOM_CA_DEST_PATH}"
    for crt_file in "${CUSTOM_CA_SRC_PATH}/"*.crt; do
      sudo openssl x509 -in "$crt_file" -out "${CUSTOM_CA_DEST_PATH}/$(basename "$crt_file")"
      sudo chown root:root "${CUSTOM_CA_DEST_PATH}/$(basename "$crt_file")"
      sudo chmod 644 "${CUSTOM_CA_DEST_PATH}/$(basename "$crt_file")"
      _changed=true
    done
    if $_changed; then sudo update-ca-trust extract; fi
  fi
fi
stage_status $_changed "Custom CA certificates"

# --- Update DNF Packages ---

sudo dnf upgrade -y --refresh
stage_status true "DNF packages upgrade"

# --- GitHub known_hosts ---

# Add GitHub to known_hosts to avoid interactive host-key prompt during git clone
mkdir -p ~/.ssh
if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  chmod 600 ~/.ssh/known_hosts
  stage_status true "GitHub -> known_hosts"
else
  stage_status false "GitHub -> known_hosts"
fi

# --- .dotfile setup ---

_changed=false
# Clone dotfiles repository
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone "${DOTFILES_CLONE_URL}" "$HOME/.dotfiles"
  _changed=true
fi

# Check if dotfiles setup script is present
if [ ! -f "$HOME/.dotfiles/setup.sh" ]; then
  echo_error "Dotfiles setup script not found. Please check the repository structure."
fi

# Set Git local overrides
if [ ! -f ~/.config/git.user/config ] && [ -n "${GIT_USER_NAME}" ] && [ -n "${GIT_USER_EMAIL}" ]; then
  mkdir -p ~/.config/git.user
  tee ~/.config/git.user/config &> /dev/null <<EOF
[core]
    autocrlf = input
[user]
    name = ${GIT_USER_NAME}
    email = ${GIT_USER_EMAIL}
EOF
  _changed=true
fi
stage_status $_changed ".dotfiles setup"

# --- .dotfile packages installation ---

# Install tools using dotfiles setup script
PACKAGES_LIST=$(printf '%s,' "${DOTFILES_PACKAGES[@]}")
bash "$HOME/.dotfiles/unattended_setup.sh" --packages "${PACKAGES_LIST%,}"
stage_status true "Standard .dotfiles packages installed"

# Install Ansible if not already installed
if [ "$INSTALL_ANSIBLE" = true ] && ! command -v ansible &> /dev/null; then
  bash "$HOME/.dotfiles/unattended_setup.sh" --packages "ansible"
  stage_status true "Ansible installation"
else
  stage_status false "Ansible installation"
fi
# Install Claude Code if not already installed
if [ "$INSTALL_CLAUDECODE" = true ] && ! command -v claude &> /dev/null; then
  bash "$HOME/.dotfiles/unattended_setup.sh" --packages "claude-code"
  stage_status true "Claude Code installation"
else
  stage_status false "Claude Code installation"
fi
# Install Docker if not already installed
if [ "$INSTALL_DOCKER" = true ] && ! command -v docker &> /dev/null; then
  bash "$HOME/.dotfiles/unattended_setup.sh" --packages "docker"
  stage_status true "Docker installation"
else
  stage_status false "Docker installation"
fi
# Install Golang if not already installed
if [ "$INSTALL_GOLANG" = true ] && ! command -v go &> /dev/null; then
  bash "$HOME/.dotfiles/unattended_setup.sh" --packages "golang"
  stage_status true "Golang installation"
else
  stage_status false "Golang installation"
fi
# Install Kubectl and Helm if not already installed
if [ "$INSTALL_KUBECTL" = true ]; then
  if ! command -v kubectl &> /dev/null; then
    bash "$HOME/.dotfiles/unattended_setup.sh" --packages "kubectl"
    stage_status true "Kubectl installation"
  else
    stage_status false "Kubectl installation"
  fi
  if ! command -v helm &> /dev/null; then
    bash "$HOME/.dotfiles/unattended_setup.sh" --packages "helm"
    stage_status true "Helm installation"
  else
    stage_status false "Helm installation"
  fi
else
  stage_status false "Kubectl installation"
  stage_status false "Helm installation"
fi
# Install Rust if not already installed
if [ "$INSTALL_RUST" = true ] && ! command -v rustc &> /dev/null; then
  bash "$HOME/.dotfiles/unattended_setup.sh" --packages "rust"
  stage_status true "Rust installation"
else
  stage_status false "Rust installation"
fi
# Install Terraform if not already installed
if [ "$INSTALL_TERRAFORM" = true ] && ! command -v terraform &> /dev/null; then
  bash "$HOME/.dotfiles/unattended_setup.sh" --packages "terraform"
  stage_status true "Terraform installation"
else
  stage_status false "Terraform installation"
fi

# --- NPM Global Packages ---

_changed=false
# Install NX globally if version is specified
if [ -n "${NX_VERSION}" ]; then
  sudo npm install -g nx@"$NX_VERSION"
  _changed=true

  # Add aliases to .zshrc
  if ! grep -q "DEV Aliases" ~/.zshrc; then
    mv ~/.zshrc ~/.zshrc.bak
    tee -a ~/.zshrc &> /dev/null <<'EOF'
# DEV aliases
alias nxrl='nx run-many --target=lint --max-warnings=0'
alias nxrt='nx run-many --target=test'
alias nxrlt='nx run-many --target=lint --max-warnings=0 & nx run-many --target=test'

EOF
    cat ~/.zshrc.bak >> ~/.zshrc
    rm ~/.zshrc.bak
  fi
fi
stage_status $_changed "NPM NX global package"

# Install Angular CLI globally if version is specified
_changed=false
if [ -n "${ANGULAR_VERSION}" ]; then
  sudo npm install -g @angular/cli@"$ANGULAR_VERSION"
  _changed=true
fi
stage_status $_changed "NPM Angular CLI global package"

# --- ZSH Configuration ---

_changed=false
# Add env variables and aliases to .zshrc, before `source /home/dev/.config/zsh/config.zsh`
if ! grep -q "DEV environment variables" ~/.zshrc; then
  mv ~/.zshrc ~/.zshrc.bak
  tee -a ~/.zshrc &> /dev/null <<'EOF'
# DEV environment variables
export NX_TUI="false"

EOF
  cat ~/.zshrc.bak >> ~/.zshrc
  rm ~/.zshrc.bak
  _changed=true
fi

# Change default shell to zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
  sudo chsh -s "/usr/bin/zsh" "$USER"
  _changed=true
fi
stage_status $_changed "ZSH configuration"

# --- VS Code (Windows) ---

_changed=false
_vscode_bin=""
_vscode_link_name="code"

# Scan typical Windows VS Code install locations: user-local first, then system-wide.
# Insiders edition checked after stable for each tier.
declare -a _vscode_candidates=()
if [ -n "${WINDOWS_USERNAME}" ]; then
  _vscode_candidates+=(
    "/mnt/c/Users/${WINDOWS_USERNAME}/AppData/Local/Programs/Microsoft VS Code/bin/code"
    "/mnt/c/Users/${WINDOWS_USERNAME}/AppData/Local/Programs/Microsoft VS Code Insiders/bin/code-insiders"
  )
fi
_vscode_candidates+=(
  "/mnt/c/Program Files/Microsoft VS Code/bin/code"
  "/mnt/c/Program Files/Microsoft VS Code Insiders/bin/code-insiders"
)

for _candidate in "${_vscode_candidates[@]}"; do
  if [ -f "$_candidate" ]; then
    _vscode_bin="$_candidate"
    [[ "$_candidate" == *"Insiders"* ]] && _vscode_link_name="code-insiders"
    break
  fi
done

if [ -n "$_vscode_bin" ]; then
  _vscode_wrapper="/usr/local/bin/${_vscode_link_name}"
  # (Re)create the wrapper if it's missing or points at a different VS Code path
  if [ ! -f "$_vscode_wrapper" ] || ! grep -qF "${_vscode_bin}" "$_vscode_wrapper" 2>/dev/null; then
    sudo tee "$_vscode_wrapper" > /dev/null <<EOF
#!/bin/sh
exec "${_vscode_bin}" "\$@"
EOF
    sudo chmod +x "$_vscode_wrapper"
    _changed=true
  fi
  stage_status $_changed "VS Code (Windows) -> /usr/local/bin/${_vscode_link_name}"
else
  stage_status false "VS Code (Windows)"
fi

# --- Projects ---

# Create projects directory
if [ ! -d ~/projects ]; then
  mkdir -p ~/projects
  stage_status true "Projects directory"
else
  stage_status false "Projects directory"
fi
