# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ASDF
source $HOME/.asdf/asdf.sh

# Plugins
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh/zsh-histdb/sqlite-history.zsh
autoload -Uz add-zsh-hook

#donet
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Functions
function up {
  sudo pacman -Syyuu --noconfirm
  yay -Syu --noconfirm
  yay --clean --noconfirm
  flatpak update --assumeyes
  flatpak remove --unused --assumeyes
}

# Alias
alias ls='exa -la --header --git --icons'
alias cat='bat'
alias history='histdb'
alias h='histdb'
alias grep='grep --color=auto'
alias meminfo='free -m -l -t'
alias ping='ping -c3'	# Default to 3 attemps instead of unlimited
alias p8='ping 8.8.8.8'
alias vi='lvim'
alias getip='curl ifconfig.me'
alias zz='vim ~/.zshrc && source ~/.zshrc'
alias gh='history|grep'
alias count='find . -type f | wc -l'
alias cpv='rsync -ah --info=progress2'
# Arch User
alias listorphans='pacman -Qtdq'
alias removeorphans="/usr/bin/pacman -Qtdq > /dev/null && sudo /usr/bin/pacman -Rs \$(/usr/bin/pacman -Qtdq | sed -e ':a;N;$!ba;s/\n/ /g')"
## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
## Get server cpu info ##
alias cpuinfo='lscpu'
alias files='cd /mnt/files'

# Exports
export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$PATH

# BindKeys
bindkey '^?'      backward-delete-char          # bs         delete one char backward
bindkey '^[[3~'   delete-char                   # delete     delete one char forward
bindkey '^[[H'    beginning-of-line             # home       go to the beginning of line
bindkey '^[[F'    end-of-line                   # end        go to the end of line
bindkey '^[[1;5C' forward-word                  # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                 # ctrl+left  go backward one word
bindkey '^H'      backward-kill-word            # ctrl+bs    delete previous word
bindkey '^[[3;5~' kill-word                     # ctrl+del   delete next word
bindkey '^J'      backward-kill-line            # ctrl+j     delete everything before cursor
bindkey '^[[D'    backward-char                 # left       move cursor one char backward
bindkey '^[[C'    forward-char                  # right      move cursor one char forward
bindkey "^[[5~"   beginning-of-history          #PageUp
bindkey "^[[6~"   end-of-history                #PageDown
