#!/bin/bash
DOWNLOAD_DIRECTORY="$HOME/Downloads/Software"
ZSH_CONFIG_FILE="zshrc"
ZSH_ENVIRONMENT_FILE="zshenv"
BASH_PROFILE="bash_profile"
AUR_SOFTWARE_INSTALL=(
  gparted
  curl
  zsh
  vim
  code
  google-chrome
  nvm
  ttf-fira-code
  brave-bin
  virtualbox
  discord
  flutter
  android-sdk
  android-sdk-platform-tools
  android-sdk-build-tools
  android-platform
)

PACMAN_SOFTWARE_INSTALL=(
  git
  docker
  htop
  fzf
)

SNAP_SOFTWARE_INSTALL=(
  spotify
  postman
  dbeaver-ce
)

echo 'Installing and updating package list'
sudo pacman -Syu --noconfirm

for software in ${PACMAN_SOFTWARE_INSTALL[@]};
do
  if ! pacman -Q | grep -q $software; then
    echo "[INSTALLING] - $software"
    sudo pacman -S "$software" --noconfirm
    echo "[DONE] - $software"
  else
    echo "[INSTALLED] - $software"
  fi
done

if ! pacman -Q | grep -q 'yay'; then
  echo '[INSTALLING] - yay'
  git clone https://aur.archlinux.org/yay.git $DOWNLOAD_DIRECTORY/yay
  makepkg -si $DOWNLOAD_DIRECTORY/yay --noconfirm
  clear
fi

for software in ${AUR_SOFTWARE_INSTALL[@]};
do
  if ! pacman -Q | grep -q $software; then
    echo "[INSTALLING] - $software"
    yay -S "$software" --noconfirm
    echo "[DONE] - $software"
  else
    echo "[INSTALLED] - $software"
  fi
done

if ! git config --global -l | grep -q 'user.name'; then
  echo "What name do you want to use in GIT user.name?"
  read git_config_user_name
  git config --global user.name "$git_config_user_name"
  clear 
fi

if ! git config --global -l | grep -q 'user.email'; then
  echo "What email do you want to use in GIT user.email?"
  read git_config_user_email
  git config --global user.email $git_config_user_email
  git config credential.helper store
  clear
fi

if ! git config --global -l | grep -q 'core.editor'; then
  echo "Can I set VIM as your default GIT editor for you? (y/n)"
  read git_core_editor_to_vim
  if echo "$git_core_editor_to_vim" | grep -iq "^y" ;then
    git config --global core.editor vim
  else
    echo "Okay, no problem. :) Let's move on!"
  fi
fi

if ! pacman -Q | grep -q 'snapd'; then
  echo '[INSTALLING] - snapd'
  git clone https://aur.archlinux.org/snapd.git $DOWNLOAD_DIRECTORY/snapd
  makepkg -s $DOWNLOAD_DIRECTORY/snapd --noconfirm
  sudo pacman -U $DOWNLOAD_DIRECTORY/snapd/*.xz --noconfirm
  echo '[START] - snapd'
  sudo systemctl start snapd
  echo '[ENABLE] - snapd'
  sudo systemctl enable snapd
fi

for software in ${SNAP_SOFTWARE_INSTALL[@]};
do
  if ! snap list | grep -q $software; then
    echo "[INSTALLING] - $software"
    sudo snap install "$software"
    echo "[DONE] - $software"
  else
    echo "[INSTALLED] - $software"
  fi
done

if ! grep -q 'source /usr/share/nvm/init-nvm.sh' ~/.$BASH_PROFILE; then 
  echo '[CONFIGURING] - nvm' 
  source /usr/share/nvm/init-nvm.sh
  echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.$BASH_PROFILE
  nvm install 12
  nvm alias default 12
  node --version
  npm --version
fi

if ! systemctl -l | grep -q 'docker.service'; then
  echo '[CONFIGURING] - docker'
  echo '[START] - docker' 
  sudo systemctl start docker
  echo '[ENABLE] - docker'
  sudo systemctl enable docker
  docker --version
  sudo chmod 777 /var/run/docker.sock
  docker run hello-world
fi

if ! systemctl -l | grep -q 'docker.service'; then
  echo '[INSTALLING] - docker-compose' 
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version
fi


if ! pacman -Q | grep -q '1password'; then
  echo '[INSTALLING] - 1password'
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
  git clone https://aur.archlinux.org/1password.git $DOWNLOAD_DIRECTORY/1password
  makepkg -si $DOWNLOAD_DIRECTORY/1password --noconfirm
fi

if ! groups $USER | grep -q 'flutterusers'; then
  echo '[PERMISSIONS] - docker'
  sudo groupadd flutterusers
  sudo gpasswd -a $USER flutterusers
  sudo chown -R :flutterusers /opt/flutter
  sudo chmod -R g+w /opt/flutter/
  sudo chown -R $USER:flutterusers /opt/flutter
fi

if ! groups $USER | grep -q 'android-sdk'; then 
  echo '[PERMISSIONS] - android-sdk'
  sudo groupadd android-sdk
  sudo gpasswd -a <user> android-sdk
  sudo setfacl -R -m g:android-sdk:rwx /opt/android-sdk
  sudo setfacl -d -m g:android-sdk:rwX /opt/android-sdk
fi
if ! grep -q 'JAVA_HOME' ~/.$ZSH_ENVIRONMENT_FILE; then
  echo 'export JAVA_HOME='/usr/lib/jvm/java-8-openjdk'
  export ANDROID_SDK_ROOT='/opt/android-sdk'
  export ANDROID_HOME='/opt/android-sdk'
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/platform-tools/
  export PATH=$PATH:$ANDROID_HOME/tools/bin/
  export PATH=$PATH:$ANDROID_HOME/tools/
  PATH=$ANDROID_HOME/emulator:$PATH' >> ~/.$ZSH_ENVIRONMENT_FILE
fi

if ! pacman -Q | grep -q 'android-studio'; then
  echo '[INSTALLING] - Android Studio'
  git clone https://aur.archlinux.org/android-studio.git $DOWNLOAD_DIRECTORY/android-studio
  makepkg -si $DOWNLOAD_DIRECTORY/android-studio --noconfirm

  echo '[INSTALLING] - android emulator'
  sdkmanager --install "system-images;android-29;default;x86"

  echo '[CREATE] - android emulator'
  avdmanager create avd -n <name> -k "system-images;android-29;default;x86"
fi

if ! pacman -Q | grep -q 'oh-my-zsh'; then
  echo '[INSTALLING] - oh-my-zsh'
  sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" 
  chsh -s /bin/zsh
fi

if ! grep -q 'reload' ~/.$ZSH_CONFIG_FILE; then
  echo '[CONFIGURING] - zsh (reload function)'
  echo "function reload(){
        source ~/.zshenv
        source ~/.zshrc
    }" >> ~/.$ZSH_CONFIG_FILE
fi


if ! grep -q 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.$ZSH_CONFIG_FILE; then 
  echo '[INSTALLING] - zsh autosuggestions' 
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.$ZSH_CONFIG_FILE
fi

if ! grep -q 'bash_profile' ~/.zshrc; then 
  echo "[CONFIGURING] - import bash_profile to zshrc"
  echo "if [ -f ~/.bash_profile ]; then 
          . ~/.bash_profile;
        fi" >> ~/.$ZSH_CONFIG_FILE
fi

echo -e "\n\n"
echo 'Restart your computer for a better experience'
echo "Don't forget to import your extensions with vscode authentication (MS or github)"
echo -e "Enjoy! =)\n\n"

