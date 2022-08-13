#!/bin/bash
set -eu

function init_config() {
    local COMMONS_FILE="commons.sh"
    source "$COMMONS_FILE"
    source "$COMMONS_CONF_FILE"
    source "$PACKAGES_CONF_FILE"
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

function copy_environment_files() {
  print_step 'copy_environment_files()'
  execute_user "cp -i ./.gitconfig /home/$USER_NAME/.gitconfig"
  echo 'What user do you want to use in GIT user.user?'
  read GITUSER
  echo 'What email do you want to use in GIT user.email?'
  read GITEMAIL
  execute_user "sed -i -e 's/<email>/$GITEMAIL/g' -e 's/<name>/$GITUSER/g' /home/$USER_NAME/.gitconfig"
  execute_user "cat ./.zshrc >> /home/$USER_NAME/.zshrc"
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
  execute_step "packages"
  execute_step "copy_environment_files"
  execute_step "set_user_to_group"
  execute_step "end"
  do_reboot
}
main $@
