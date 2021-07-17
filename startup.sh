echo 'Installing and updating package list'
sudo pacman -Syu

echo 'installing git'
sudo pacman -S git --noconfirm

echo 'installing yay'
cd ~/Downloads/
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S gparted
cd ..
clear 

echo 'installing curl' 
yay -S curl --noconfirm

echo "What name do you want to use in GIT user.name?"
read git_config_user_name
git config --global user.name "$git_config_user_name"
clear 

echo "What email do you want to use in GIT user.email?"
read git_config_user_email
git config --global user.email $git_config_user_email
clear

echo "Can I set VIM as your default GIT editor for you? (y/n)"
read git_core_editor_to_vim
if echo "$git_core_editor_to_vim" | grep -iq "^y" ;then
	git config --global core.editor vim
else
	echo "Okay, no problem. :) Let's move on!"
fi

echo "Generating a SSH Key"
ssh-keygen -t rsa -b 4096 -C $git_config_user_email
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub | xclip -selection clipboard

echo 'installing zsh'
yay -S zsh --noconfirm
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
chsh -s /bin/zsh

echo 'configuring zsh function reload'
echo "function reload(){
       source ~/.zshenv
       source ~/.zshrc
   }" >> ~/.zshrc

echo 'installing tool to handle clipboard via CLI'
yay -S xclip --noconfirm

export alias pbcopy='xclip -selection clipboard'
export alias pbpaste='xclip -selection clipboard -o'
source ~/.zshrc

echo 'installing vim'
yay -S vim --noconfirm
clear

echo 'installing code'
yay -S code --noconfirm

echo 'installing snapd'
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -s
sudo pacman -U snapd-2.30-9-x86_64.pkg.tar.xz --noconfirm
sudo systemctl enable snapd
cd ..

echo 'installing spotify' 
sudo snap install spotify

echo 'installing chrome' 
yay -S google-chrome --noconfirm

echo 'installing nvm' 
yay -S nvm --noconfirm
source /usr/share/nvm/init-nvm.sh
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.zshrc

reload #zsh function
nvm --version
nvm install 12
nvm alias default 12
node --version
npm --version

echo 'installing autosuggestions' 
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
source ~/.zshrc

echo 'installing fonts fira-code'
yay -S ttf-fira-code --noconfirm

echo 'installing terminator'
yay -S terminator --noconfirm

echo 'adding dracula theme' 
cat <<EOF >  ~/.config/terminator/config
[global_config]
  title_transmit_bg_color = "#ad7fa8"
[keybindings]
  close_term = <Primary>w
  close_window = <Primary>q
  new_tab = <Primary>t
  new_window = <Primary>i
  paste = <Primary>v
  split_horiz = <Primary>e
  split_vert = <Primary>d
  switch_to_tab_1 = <Primary>1
  switch_to_tab_10 = <Primary>0
  switch_to_tab_2 = <Primary>2
  switch_to_tab_3 = <Primary>3
  switch_to_tab_4 = <Primary>4
  switch_to_tab_5 = <Primary>5
  switch_to_tab_6 = <Primary>6
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    cursor_color = "#aaaaaa"
EOF


cat <<EOF >>  ~/.config/terminator/config
[[Dracula]]
    background_color = "#1e1f29"
    background_darkness = 0.88
    background_type = transparent
    copy_on_selection = True
    cursor_color = "#bbbbbb"
    foreground_color = "#f8f8f2"
    palette = "#000000:#ff5555:#50fa7b:#f1fa8c:#bd93f9:#ff79c6:#8be9fd:#bbbbbb:#555555:#ff5555:#50fa7b:#f1fa8c:#bd93f9:#ff79c6:#8be9fd:#ffffff"
    scrollback_infinite = True
EOF

echo 'installing docker' 
sudo pacman -S docker --noconfirm
sudo systemctl start docker
sudo systemctl enable docker
docker --version

sudo chmod 777 /var/run/docker.sock
docker run hello-world

echo 'installing docker-compose' 
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo 'installing fzf'
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo 'installing brave'
yay -S brave-bin --noconfirm

echo 'installing dbeaver'
sudo snap install dbeaver-ce

echo 'installing postman'
sudo snap install postman

echo 'installing virtualbox'
yay -S virtualbox --noconfirm

echo 'installing htop'
sudo pacman -S htop --noconfirm

echo 'installing discord'
yay -S discord --noconfirm

echo 'installing 1password'
cd ~/Downloads
curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
git clone https://aur.archlinux.org/1password.git
cd 1password
makepkg -si
cd ..

echo 'installing flutter'
echo 'Alert: Choose Openjdk 8 or 10'
yay -S flutter --noconfirm

echo 'fixing permissions'
sudo groupadd flutterusers
sudo gpasswd -a $USER flutterusers
sudo chown -R :flutterusers /opt/flutter
sudo chmod -R g+w /opt/flutter/
sudo chown -R $USER:flutterusers /opt/flutter

echo 'installing Android SDK and Tools'
yay -S android-sdk android-sdk-platform-tools android-sdk-build-tools --noconfirm
yay -S android-platform # installs the latest --noconfirm

echo 'fixing permissions'
sudo groupadd android-sdk
sudo gpasswd -a <user> android-sdk
sudo setfacl -R -m g:android-sdk:rwx /opt/android-sdk
sudo setfacl -d -m g:android-sdk:rwX /opt/android-sdk

echo 'export JAVA_HOME='/usr/lib/jvm/java-8-openjdk'
export ANDROID_SDK_ROOT='/opt/android-sdk'
export ANDROID_HOME='/opt/android-sdk'
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools/
export PATH=$PATH:$ANDROID_HOME/tools/bin/
export PATH=$PATH:$ANDROID_HOME/tools/
PATH=$ANDROID_HOME/emulator:$PATH' >> ~/.zshenv

echo 'installing Android Studio'
cd ~/Downloads
git clone https://aur.archlinux.org/android-studio.git
cd android-studio
makepkg -si
cd ..

echo 'installing android emulator'
sdkmanager --install "system-images;android-29;default;x86"

echo 'creating android emulator'
avdmanager create avd -n <name> -k "system-images;android-29;default;x86"

echo -e '\n\n\n\n'
echo 'Done! Don't forget to import your extensions with vscode authentication (MS or github)'
echo 'enjoy! =)'


