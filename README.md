# archlinux-setup


```console
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
```

It is a simple Bash script developed to Arch linux post installation

Currently these scripts are for me but maybe they are useful for you too.

For new features, improvements and bugs fill an issue in GitHub or make a pull request. You can test it in a virtual machine (strongly recommended) like [VirtualBox](https://www.virtualbox.org/) before run it in real hardware.

### Step by step

- Enable apparmor - [read more](https://wiki.archlinux.org/title/AppArmor)
- Disable Xorg as Root - [read more](https://wiki.archlinux.org/title/xorg#Rootless_Xorg)
- Enable firewall with basic rules
- Enable Flatpak
- Enable Snap
- Enable AUR
- Install essentials apps - pacman - [read more](https://github.com/RogerioSobrinho/arch-workstation-setup/blob/master/packages.conf)
- Install essentials apps - flatpak - [read more](https://github.com/RogerioSobrinho/arch-workstation-setup/blob/master/packages.conf)
- Install essentials apps - snap - [read more](https://github.com/RogerioSobrinho/arch-workstation-setup/blob/master/packages.conf)
- Install essentials apps - aur - [read more](https://github.com/RogerioSobrinho/arch-workstation-setup/blob/master/packages.conf)
- Enable Nvidia (proprietary driver)
- Apply monitor settings
- Git config - [read more](https://github.com/RogerioSobrinho/arch-workstation-setup/blob/master/dotfiles/.gitconfig)
- Install Docker + Docker compose
- Install DE (Gnome)
- Enable Bluetooth
- Enable OpenVPN
- Enable CUPS
- Install ZSH with plugins (powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, zsh-histdb)
- Enable ASDF - [read more](https://asdf-vm.com/)
- Enable LunarVIM - [read more](https://www.lunarvim.org/)
- Enable ProtonGE Custom (Steam) - [read more](https://github.com/GloriousEggroll/proton-ge-custom)
- Remove unnecessary shortcuts

### Run the command below to start the script:

```bash
$ ./startup.sh
```

## Show your support

Give a ⭐️ if this project helped you!
