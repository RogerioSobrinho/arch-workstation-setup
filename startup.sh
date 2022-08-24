#!/bin/bash
set -eu

function init_config() {
    local COMMONS_FILE="commons.sh"
    source "$COMMONS_FILE"
    source "$COMMONS_CONF_FILE"
    source "$PACKAGES_CONF_FILE"
}

function config_mirror() {
    print_step 'config_mirror()'
    if [ "$REFLECTOR" == 'true' ]; then
        pacman_install 'reflector'
        execute_sudo "reflector --country $REFLECTOR_COUNTRIES --latest 5 --sort rate --completion-percent 100 --save /etc/pacman.d/mirrorlist"
    fi
}

function packages() {
    print_step 'packages()'
    USER_NAME="$USER_NAME" \
        ./packages.sh
    if [ "$?" != "0" ]; then
        exit 1
    fi
}

function set_user_to_group() {
  print_step 'set_user_to_group()'
  if pacman -Q | grep -q 'docker'; then
    execute_sudo 'groupadd docker'
    execute_sudo "usermod -aG docker $USER_NAME"
  fi
}

function copy_dotfiles() {
  print_step 'copy_dotfiles()'
  execute_user "cp -i ./.gitconfig $HOME/.gitconfig"
  execute_user "cp -i ./.zshrc $HOME/.zshrc"
}

function install_plugins_to_zsh() {
  print_step 'install_plugins_to_zsh()'
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

function install_lvim() {
  print_step 'install_lvim()'
  execute_user 'bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)'
}

function config_laptop() {
    print_step 'config_laptop()'
    if [ "$LAPTOP" == 'Acer Nitro' ]; then
        execute_sudo 'nbfc config --set "Acer Nitro AN515-51"'
    fi
}

function main() {
  init_config
  execute_step "config_mirror"
  execute_step "packages"
  execute_step "copy_dotfiles"
  execute_step "install_plugins_to_zsh"
  execute_step "config_laptop"
  execute_step "set_user_to_group"
  execute_step "install_lvim"
  do_reboot
}
main $@
