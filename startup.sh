#!/bin/bash
set -eu

function init_config() {
    local COMMONS_FILE="commons.sh"
    source "$COMMONS_FILE"
    source "$COMMONS_CONF_FILE"
    source "$PACKAGES_CONF_FILE"
}

function apparmor() {
  print_step 'apparmor'
  pacman_install 'apparmor'
  execute_sudo 'systemctl enable apparmor'
  # TODO add kernel parameter
}

function xorgRootless() {
  print_step 'xorgRootless'
  execute_sudo "echo 'needs_root_rights = no' >> /etc/X11/Xwrapper.config"
}

function firewall() {
  print_step 'firewall'
  pacman_install ufw gufw
  execute_sudo 'sudo ufw limit 22/tcp /
sudo ufw allow 80/tcp /
sudo ufw allow 443/tcp /
sudo ufw default deny incoming /
sudo ufw default allow outgoing /
sudo ufw enable'
}

function packages() {
    print_step 'packages()'
    USER_NAME="$USER_NAME" \
        ./packages.sh
    if [ "$?" != "0" ]; then
        exit 1
    fi
}

function nvidia() {
  print_step 'nvidia'
  pacman_install 'nvidia nvidia-settings nvidia-prime'
  execute_sudo "systemctl enable nvidia-persistenced.service"
}

function multimonitor() {
  print_step 'multimonitor'
  execute_user "cp -iu ./files/monitors.xml $HOME/.config/monitors.xml"
}

function dotfiles() {
  print_step 'dotfiles()'
  execute_user "cp -iu ./dotfiles/.gitconfig $HOME/.gitconfig"
  execute_user "cp -iu ./dotfiles/.zshrc $HOME/.zshrc"
}

function docker() {
  print_step 'docker()'
  pacman_install 'docker docker-compose'
  execute_sudo "systemctl enable docker.service"
  execute_sudo "usermod -aG docker $USER_NAME"
}

function install_DE() {
  print_step 'install_DE'
  pacman_install 'gnome-shell gedit gnome-control-center nautilus gnome-terminal gnome-tweak-tool xdg-user-dirs gdm gnome-clocks gnome-weather gnome-calendar eog sushi gnome-boxes gnome-keyring networkmanager evince gnome-calculator gnome-system-monitor gnome-themes-extra gnome-backgrounds'
  execute_sudo "systemctl enable gdm.service"
  execute_sudo "systemctl enable NetworkManager.service"
}

# TODO
# function extensions_DE() {
#   print_step 'extensions_DE'
  
# }

function bluetooth() {
  print_step 'bluetooth'
  pacman_install 'bluez bluez-utils'
  execute_sudo "systemctl enable bluetooth.service"
}

function openVPN() {
  print_step 'openVPN'
  pacman_install 'openvpn networkmanager-openvpn'
}

function cups() {
  print_step 'cups'
  pacman_install 'cups'
  execute_sudo "systemctl enable cups.service"
  execute_sudo "systemctl enable cups-browsed.service"
}

function zsh() {
  print_step 'zsh()'
  pacman_install 'zsh'
  execute_user 'chsh -s $(which zsh)' # set zsh to default
  execute_user "wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P $HOME/.local/share/fonts"
  execute_user "wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -P $HOME/.local/share/fonts"
  execute_user "wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -P $HOME/.local/share/fonts"
  execute_user "wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -P $HOME/.local/share/fonts"
  execute_user 'fc-cache -fv'
  execute_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k"
  execute_user "git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/zsh-autosuggestions"
  execute_user "git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.zsh/zsh-syntax-highlighting"
  execute_user "git clone https://github.com/larkery/zsh-histdb $HOME/.zsh/zsh-histdb"
}

function asdf() {
  print_step 'asdf'
  execute_user 'git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2'
}

# TODO
# function lvim() {
#   print_step 'lvim'
  
# }

function protonGE() {
  print_step 'protonGE'
  execute_user "wget https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton7-35/GE-Proton7-35.tar.gz -P /tmp"
  execute_user 'mkdir ~/.steam/root/compatibilitytools.d'
  execute_user "tar -xf /tmp/GE-Proton7-35.tar.gz -C ~/.steam/root/compatibilitytools.d/"
}

function removeShortcuts() {
  print_step 'removeShortcuts'
  execute_sudo 'mv /usr/share/applications/display-im6.q16.desktop /usr/share/applications/display-im6.q16.desktop.bkp'
  execute_sudo 'mv /usr/share/applications/htop.desktop /usr/share/applications/htop.desktop.bkp'
  execute_sudo 'mv /usr/share/applications/nvim.desktop /usr/share/applications/nvim.desktop.bkp'
  execute_sudo 'mv /usr/share/applications/vim.desktop /usr/share/applications/vim.desktop.bkp'
}

function main() {
  init_config
  execute_step "apparmor"
  execute_step "xorgRootless"
  execute_step "firewall"
  execute_step "packages"
  execute_step "nvidia"
  execute_step "multimonitor"
  execute_step "dotfiles"
  execute_step "docker"
  execute_step "install_DE"
  execute_step "bluetooth"
  execute_step "openVPN"
  execute_step "cups"
  execute_step "zsh"
  execute_step "asdf"
  execute_step "protonGE"
  execute_step "removeShortcuts"
}
main $@
