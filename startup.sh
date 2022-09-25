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
  execute_sudo "sed -i '/^options/ s/$/ lsm=landlock,lockdown,yama,integrity,apparmor,bpf /' /boot/loader/entries/*.conf"
}

function xorg_rootless() {
  print_step 'xorgRootless'
  execute_sudo "echo 'needs_root_rights = no' >> /etc/X11/Xwrapper.config"
}

function firewall() {
  print_step 'firewall'
  pacman_install ufw gufw
  execute_sudo 'ufw limit 22/tcp'
  execute_sudo 'ufw allow 80/tcp'
  execute_sudo 'ufw allow 443/tcp'
  execute_sudo 'ufw default deny incoming'
  execute_sudo 'ufw default allow outgoing'
  execute_sudo 'ufw enable'
}

function pacman_conf() {
    print_step 'pacman_conf()'
    execute_sudo "sed -i 's/#ParallelDownloads/ParallelDownloads' /etc/pacman.conf"
    execute_sudo "sed -i '/\[multilib\]/,/Include/''s/^#//' /etc/pacman.conf"
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
  pacman_install 'gnome-shell gedit gnome-control-center /
  nautilus gnome-terminal gnome-tweak-tool xdg-user-dirs /
  gdm gnome-clocks gnome-weather gnome-calendar eog sushi /
  gnome-boxes gnome-keyring networkmanager evince gnome-calculator / 
  gnome-system-monitor gnome-themes-extra gnome-backgrounds'
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
  set +e
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
  set -e
}

function asdf() {
  print_step 'asdf'
  set +e
  execute_user 'git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2'
  set -e
}

function lvim() {
  print_step 'lvim'
  set +e
  execute_user 'bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) -y'
  set -e
}

function protonGE() {
  print_step 'protonGE'
  set +e
  execute_user "wget https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton7-35/GE-Proton7-35.tar.gz -P /tmp"
  execute_user 'mkdir -p ~/.steam/steam/compatibilitytools.d'
  execute_user "tar -xf /tmp/GE-Proton7-35.tar.gz -C ~/.steam/steam/compatibilitytools.d/"
  set -e
}

function remove_shortcuts() {
  print_step 'removeShortcuts'
  local APPLICATIONS_FOLDER='/usr/share/applications'
  SHORTCUTS=('avahi-discover.desktop' 'htop.desktop' /
  'nvim.desktop' 'vim.desktop' /
  'qvidcap.desktop' 'qv4l2.desktop' /
  'bssh.desktop' 'bvnc.desktop' /
  'java-java11-openjdk.desktop' 'jconsole-java11-openjdk.desktop' /
  'jshell-java11-openjdk.desktop' 'cmake-gui.desktop')
  set +e
  for shortcut in "${SHORTCUTS[@]}"
  do
    disable_file "$APPLICATIONS_FOLDER" "$zone"
  done
  set -e
}

function print_logo() {
  cat <<'EOF'
    _             _     
   / \   _ __ ___| |__  
  / _ \ | '__/ __| '_ \ 
 / ___ \| | | (__| | | |
/_/   \_\_|  \___|_| |_|
                        
__        __         _        _        _   _             
\ \      / /__  _ __| | _____| |_ __ _| |_(_) ___  _ __  
 \ \ /\ / / _ \| '__| |/ / __| __/ _` | __| |/ _ \| '_ \ 
  \ V  V / (_) | |  |   <\__ \ || (_| | |_| | (_) | | | |
   \_/\_/ \___/|_|  |_|\_\___/\__\__,_|\__|_|\___/|_| |_|
                                                         
 ____       _               
/ ___|  ___| |_ _   _ _ __  
\___ \ / _ \ __| | | | '_ \ 
 ___) |  __/ |_| |_| | |_) |
|____/ \___|\__|\__,_| .__/ 
                     |_|  
EOF
}

function main() {
  print_logo
  init_config
  execute_step "apparmor"
  execute_step "xorg_rootless"
  execute_step "firewall"
  execute_step "pacman_conf"
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
  execute_step "lvim"
  execute_step "protonGE"
  execute_step "remove_shortcuts"
}
main $@
