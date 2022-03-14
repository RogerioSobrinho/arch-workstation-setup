#!/bin/bash bash
set -eu
PACKAGES_CONF_FILE="packages.conf"
COMMONS_CONF_FILE="commons.conf"

GREEN='\033[0;92m'
BLUE='\033[0;96m'
WHITE='\033[0;97m'
NC='\033[0m'

function print_step() {
    STEP="$1"
    echo ""
    echo -e "${BLUE}# ${STEP} step${NC}"
    echo ""
}

function do_reboot() {
    reboot --reboot
}

function execute_step() {
    local STEP="$1"
    eval "$STEP"
}

function pacman_install() {
    local ERROR="true"
    set +e
    IFS=' ' local PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        execute_sudo "$COMMAND"
        if [ $? == 0 ]; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit 1
    fi
}

function aur_install() {
    local ERROR="true"
    set +e
    which "$AUR_COMMAND"
    if [ "$AUR_COMMAND" != "0" ]; then
        aur_command_install "$USER_NAME" "$AUR_PACKAGE"
    fi
    IFS=' ' local PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        local COMMAND="$AUR_COMMAND -Syu --noconfirm --needed ${PACKAGES[@]}"
        execute_sudo "$COMMAND"
        if [ $? == 0 ]; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        return
    fi
}

function flatpak_install() {
    local ERROR="true"
    set +e
    IFS=' ' local PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        local COMMAND="flatpak install -y flathub ${PACKAGES[@]}"
        execute_sudo "$COMMAND"
        if [ $? == 0 ]; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        return
    fi
}

function aur_command_install() {
    pacman_install "git"
    local USER_NAME="$1"
    local COMMAND="$2"
    execute_sudo "rm -rf /home/$USER_NAME/.alis/aur/$COMMAND && mkdir -p /home/$USER_NAME/.alis/aur && cd /home/$USER_NAME/.alis/aur && git clone https://aur.archlinux.org/$COMMAND.git && (cd $COMMAND && makepkg -si --noconfirm) && rm -rf /home/$USER_NAME/.alis/aur/$COMMAND"
}

function sanitize_variable() {
    local VARIABLE="$1"
    local VARIABLE=$(echo "$VARIABLE" | sed "s/![^ ]*//g") # remove disabled
    local VARIABLE=$(echo "$VARIABLE" | sed -r "s/ {2,}/ /g") # remove unnecessary white spaces
    local VARIABLE=$(echo "$VARIABLE" | sed 's/^[[:space:]]*//') # trim leading
    local VARIABLE=$(echo "$VARIABLE" | sed 's/[[:space:]]*$//') # trim trailing
    echo "$VARIABLE"
}

function init_log() {
    local ENABLE="$1"
    local FILE="$2"
    if [ "$ENABLE" == "true" ]; then
        exec > >(tee -a $FILE)
        exec 2> >(tee -a $FILE >&2)
        set -o xtrace
    fi
}

function execute_sudo() {
    local COMMAND="$1"
    sudo bash -c "$COMMAND"
}

function execute_user() {
    local COMMAND="$1"
    bash -c "$COMMAND"
}

