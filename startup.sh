#!/bin/bash
set -eu

function init_config() {
    local COMMONS_FILE="commons.sh"

    source "$COMMONS_FILE"
    source "$COMMONS_CONF_FILE"
    source "$PACKAGES_CONF_FILE"
}

function set_dark_theme(){
  print_step "set_dark_theme()"
  if pacman -Q | grep -q 'gnome'; then
    execute_user "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"
  fi
}

function install_gnome_environment() {
  print_step "install_gnome_environment()"
  pacman_install 'gnome xorg gnome-terminal nautilus gnome-tweaks gnome-control-center gnome-backgrounds adwaita-icon-theme gnome-themes-extra'
  execute_sudo 'systemctl enable gdm.service'
}

function config_power10k() {
  print_step "config_power10k()"
  if pacman -Q | grep -q 'zsh-theme-powerlevel10k-git'; then
    execute_user 'chsh -s $(which zsh)' # set zsh to default
    execute_user 'wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P /home/$USER_NAME/.fonts'
    execute_user 'wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -P /home/$USER_NAME/.fonts'
    execute_user 'wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -P /home/$USER_NAME/.fonts'
    execute_user 'wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -P /home/$USER_NAME/.fonts'
    execute_user 'fc-cache -fv'

    if pacman -Q | grep -q 'gnome-terminal'; then
      execute_user "gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ font 'MesloLGS NF 12'"
    fi

    if ! cat ~/.zshrc | grep "autosuggestions"; then 
      execute_user 'git clone https://github.com/zsh-users/zsh-autosuggestions /home/$USER_NAME/.zsh/zsh-autosuggestions'
    fi
    if ! cat ~/.zshrc | grep "zsh-histdb"; then 
      execute_user 'git clone https://github.com/larkery/zsh-histdb /home/$USER_NAME/.zsh/zsh-histdb'
    fi
  fi
}

function install_lunaVim() {
  print_step "install_lunaVim()"
  if pacman -Q | grep "neovim"; then 
    execute_user 'bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)'
  fi
}

function packages() {
    print_step "packages()"
    USER_NAME="$USER_NAME" \
        ./packages.sh
    if [ "$?" != "0" ]; then
        exit 1
    fi
}

function set_user_to_group() {
  print_step "set_user_to_group()"
  if pacman -Q | grep -q 'docker'; then
    execute_sudo 'tee /etc/modules-load.d/loop.conf <<< "loop"'
    execute_sudo 'modprobe loop'
    execute_sudo 'groupadd docker'
    execute_sudo 'usermod -aG docker $USER_NAME'
  fi

  if pacman -Q | grep -q 'flutter'; then
    execute_sudo 'gpasswd -a $USER_NAME flutterusers'
  fi

  if pacman -Q | grep -q 'android'; then 
    execute_sudo 'groupadd android-sdk'
    execute_sudo 'gpasswd -a $USER_NAME android-sdk'
    execute_sudo 'setfacl -R -m g:android-sdk:rwx /opt/android-sdk'
    execute_sudo 'setfacl -d -m g:android-sdk:rwX /opt/android-sdk'
  fi
}

function copy_environment_files() {
  print_step "copy_environment_files()"
  execute_user "cp -i ./.gitconfig /home/$USER_NAME/.gitconfig"
  echo "What user do you want to use in GIT user.user?"
  read git_user_name
  echo "What email do you want to use in GIT user.email?"
  read git_user_email
  execute_user "sed -i -e 's/<email>/$git_user_email/g' -e 's/<name>/$git_user_name/g' /home/$USER_NAME/.gitconfig"
  execute_sudo "cp -i ./.zshrc /home/$USER_NAME/.zshrc"
}

function set_config_to_nitro() {
  print_step "set_config_to_nitro()"
  execute_step "config_optimus_to_hybrid_mode"
  execute_step "config_coolerConf"
}

function config_optimus_to_hybrid_mode(){
  print_step "config_optimus_to_hybrid_mode()"
  if pacman -Q | grep -q 'optimus'; then 
    execute_sudo 'cp -i ./nitro-config/80-nvidia-pm.rules /lib/udev/rules.d/80-nvidia-pm.rules'
    execute_sudo 'echo "options nvidia "NVreg_DynamicPowerManagement=0x02"" > /etc/modprobe.d/nvidia.conf'
    execute_sudo 'cp -i ./nitro-config/powertop.service /etc/systemd/system/powertop.service'
    execute_sudo 'cp -i ./nitro-config/optimus-manager.conf /etc/optimus-manager/optimus-manager.conf'
  fi
}

function config_coolerConf(){
  print_step "config_coolerConf()"
 if pacman -Q | grep -q 'nbfc'; then
    execute_sudo 'nbfc config -r'
    execute_sudo 'nbfc config -a "Acer Predator G3-572"'
  fi
}

function end() {
  echo -e "\n\n"
  echo 'I will reboot your computer for a better experience'
  echo -e 'Enjoy! =)'
  echo -ne '>>>                       [20%]\r'
  sleep 2
  echo -ne '>>>>>>>                   [40%]\r'
  sleep 2
  echo -ne '>>>>>>>>>>>>>>            [60%]\r'
  sleep 2
  echo -ne '>>>>>>>>>>>>>>>>>>>>>>>   [80%]\r'
  sleep 2
  echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\r'
  echo -ne '\n'
  echo -e '\n\n'
}

function main() {
  init_config
  execute_step "install_gnome_environment"
  execute_step "set_dark_theme"
  execute_step "packages"
  execute_step "copy_environment_files"
  execute_step "set_user_to_group"
  execute_step "set_config_to_nitro"
  execute_step "config_power10k"
  execute_step "install_lunaVim"
  execute_step "end"
  do_reboot
}
main $@
