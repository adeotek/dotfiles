#!/bin/bash

###
# Oh-My-Posh install and config script
# One line run:
# /bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/adeotek/b3b9997773172f5bbd0b4ff75bb2c5b2/raw/oh-my-posh-setup.sh)"
###

DEB_FONTS_DIR=".fonts"
RHEL_FONTS_DIR=".local/share/fonts"
BIN_FILE="/usr/local/bin/oh-my-posh"
declare -A ARGS=(
    ["fonts"]=0
    ["bin"]=0
    ["theme"]=0
    ["full-theme"]=0
    ["homebrew"]=0
)

# Global system variables
CURRENT_OS_ID="$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)"
CURRENT_OS_VER="$(sed -n 's/^VERSION_ID=\(.*\)/\1/p' /etc/os-release)"

install_homebrew () {
    if ! brew --version >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/dev/.bashrc
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"   
        sudo apt-get install -y build-essential
        brew install gcc
    fi
}

set_fonts () {
    # Install or Update CaskaydiaCove Nerd Font Mono
    if [[ ! -d ~/$1 ]]; then
        mkdir ~/$1
    fi
    if [[ -d ~/$1/CascadiaCode ]]; then
        rm -rf ~/$1/CascadiaCode
    else
        if [ "$CURRENT_OS_ID" -eq "fedora" ]; then
            sudo dnf install -y fontconfig
        else
            sudo apt install -y fontconfig
        fi
    fi
    ## Download fonts
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip -O ~/CascadiaCode.zip
    ## Unpack fonts
    unzip ~/CascadiaCode.zip -d ~/$1/CascadiaCode
    rm ~/CascadiaCode.zip
    ## Configure fonts
    fc-cache -fv
}

set_bin () {
    if [[ "$2" -eq 1 ]]; then
        # install Oh My Posh using homebrew
        if oh-my-posh >/dev/null 2>$1; then
            brew update && brew upgrade oh-my-posh
        else
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
        fi
    else
        # Install or Update Oh My Posh binary
        if [[ -f "$1" ]]; then
            sudo rm $1
        fi

        ARCH=$(uname -m)
        if [[ "$ARCH" == "aarch64" ]]; then
            sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64 -O $1
        else
            sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O $1
        fi
        sudo chmod +x $1
    fi
}

set_theme () {
    # Install Oh My Posh custom theme
    if [[ -f "~/$1" ]]; then
        rm ~/$1
    fi
    wget https://gist.githubusercontent.com/adeotek/0cccb275b9a8acd909cdbef367baa8d5/raw/$1 -O ~/$1
}

set_bash_profile () {
    IS_PROFILE_SET=$(cat ~/.bashrc | grep "oh-my-posh --init --shell bash")
    if [[ -z "$IS_PROFILE_SET" ]]; then
        # Add bash config in .bashrc
        (echo; echo "# Oh My Posh bash config"; echo "eval \"\$(oh-my-posh --init --shell bash --config ~/$1)\"") >> ~/.bashrc
        ## Apply .bashrc changes
        source ~/.bashrc
    fi
}

# Args
if [[ "$1" == "--help" ]]; then
    printf "Usage:\n"
    printf "\t./oh-my-posh-setup.sh [options/flags]\n\n"
    printf "Available options/flags:\n"
    for key in "${!ARGS[@]}"; do
        printf "\t--%s\n" "$key"
    done
    printf "\n"
    exit 0
fi

if [[ $# == 0 ]]; then
    ARGS_ALL=1
else
    ARGS_ALL=0
fi
while [[ $# -gt 0 ]]; do
    case $1 in
        --*)
            if [[ ! -v ARGS[${1:2}] ]]; then
                echo "ERROR: Invalid argument/flag: $1!"
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
            echo "ERROR: Unknown argument/flag: $1!"
            exit 2
        ;;
    esac
    shift
done

# MAIN
if [[ "${ARGS["homebrew"]}" -eq 1 ]]; then
    install_homebrew
fi
if [[ "${ARGS["full-theme"]}" -eq 1 || "$ARGS_ALL" -eq 1 ]]; then
    THEME_FILE="gbs.omp.yaml"
else
    THEME_FILE="gbs-text.omp.yaml"
fi
if [[ "${ARGS["fonts"]}" -eq 1 || "$ARGS_ALL" -eq 1 ]]; then
    if [ "$CURRENT_OS_ID" -eq "fedora" ]; then
        set_fonts $RHEL_FONTS_DIR
    else
        set_fonts $DEB_FONTS_DIR
    fi
fi
if [[ "${ARGS["bin"]}" -eq 1 || "$ARGS_ALL" -eq 1 ]]; then
    set_bin $BIN_FILE ${ARGS["homebrew"]}
fi
if [[ "${ARGS["theme"]}" -eq 1 || "$ARGS_ALL" -eq 1 ]]; then
    set_theme $THEME_FILE
fi
set_bash_profile $THEME_FILE
echo OhMyPosh setup DONE!
# END
