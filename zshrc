#####################
# ZINIT             #
#####################
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing zinit…%f"
    command mkdir -p $HOME/.zinit
    command git clone https://github.com/zdharma-continuum/zinit $HOME/.zinit/bin && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
        print -P "%F{160}▓▒░ The clone has failed.%F"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

#####################
# THEME             #
#####################

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zinit ice depth=1; zinit light romkatv/powerlevel10k

#####################
# PLUGINS           #
#####################
# HISTORY SUBSTRING SEARCHING
# function _history_substring_search_config() {
#     bindkey "$terminfo[kcuu1]" history-substring-search-up
#     bindkey "$terminfo[kcud1]" history-substring-search-down
#     bindkey '^[[A' history-substring-search-up
#     bindkey '^[[B' history-substring-search-down
#     bindkey -M vicmd 'k' history-substring-search-up
#     bindkey -M vicmd 'j' history-substring-search-down

#     # Enable fuzzy search
#     export HISTORY_SUBSTRING_SEARCH_FUZZY='activate'

#     export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=red,bold"
# }

# zinit ice wait'0b' silent \
#   atload'zicompinit; zicdreplay; _history_substring_search_config' \
# zinit light zsh-users/zsh-history-substring-search

# TAB COMPLETIONS
zinit ice wait"0b" lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions
# Case insensitive matches if nothing found
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:complete:*:options' sort false
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':fzf-tab:*' single-group ''
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':completion:*' special-dirs true

zstyle ":fzf-tab:complete:(exa|ls|bat|cat|nvim|vim|rm|cd|cp|mv):*" fzf-preview '
  bat --style=numbers --color=always --line-range :250 $realpath 2>/dev/null ||
  exa -1 --color=always --icons --group-directories-first $realpath
'
# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
# FZF
zinit ice lucid wait'0b' from"gh-r" as"program"
zinit light junegunn/fzf
# FZF BYNARY AND TMUX HELPER SCRIPT
zinit ice lucid wait'0c' as"command" pick"bin/fzf-tmux"
zinit light junegunn/fzf
# BIND MULTIPLE WIDGETS USING FZF
zinit ice lucid wait'0c' multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zinit light junegunn/fzf
# FZF-TAB
zinit ice wait"1" lucid atinit"zicompinit;zicdreplay"
zinit light Aloxaf/fzf-tab
# SYNTAX HIGHLIGHTING
# zinit ice wait"0c" lucid atinit"zpcompinit;zpcdreplay"
# zinit light zdharma/fast-syntax-highlighting
# BAT
zinit ice from"gh-r" as"program" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat
# EXA
zinit ice wait"2" lucid from"gh-r" as"program" mv"bin/exa* -> exa" atload"alias ls=exa"
zinit light ogham/exa
# PIP completions
zinit ice wait"2" svn lucid
zinit snippet OMZ::plugins/pip
# THE FUCK - type fuck after invalid command
zplugin ice wait'1' lucid
zplugin light laggardkernel/zsh-thefuck

#####################
# HISTORY           #
#####################
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zhistory"
HISTSIZE=290000
SAVEHIST=$HISTSIZE

#####################
# SETOPT            #
#####################
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
# setopt share_history          # share command history data
setopt always_to_end          # cursor moved to the end in full completion
setopt hash_list_all          # hash everything before completion
# setopt completealiases        # complete alisases
setopt complete_in_word       # allow completion from within a word/phrase
setopt nocorrect              # spelling correction for commands
setopt list_ambiguous         # complete as much of a completion until it gets ambiguous.
setopt nolisttypes
setopt listpacked
setopt automenu

#####################
# VI-MODE           #
#####################

bindkey -v

# Fix backspace after normal mode
bindkey "^?" backward-delete-char

# allow V to edit the command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'V' edit-command-line

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

full-fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)BUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N full-fzf-history-widget
bindkey -M vicmd '/' full-fzf-history-widget

#####################
# ENV VARIABLE      #
#####################
export EDITOR='nvim'
export BAT_THEME="base16"
# export ZSH_DISABLE_COMPFIX=true

# Mute all bells
unsetopt BEEP

# 10ms for key sequences
KEYTIMEOUT=1

export GOPATH="${HOME}/.go"
export GOROOT="/usr/local/opt/go/libexec"

# export PYTHONROOT="$(brew --prefix python)/bin"
export PYTHONROOT="/usr/local/opt/python/bin"

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$HOME/.cargo/bin:$HOME/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:${GOPATH}/bin:${GOROOT}/bin:${PYTHONROOT}:$PATH"

export SBT_CREDENTIALS="$HOME/.sbt/.credentials"
export SBT_OPTS="-XX:+CMSClassUnloadingEnabled -Xmx2G"

# export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

#####################
# COLORING          #
#####################
autoload colors && colors

#####################
# ALIASES           #
#####################
alias vim="nvim"

# OS specific alisases
if [[ "$(uname 2> /dev/null)" == "Linux" ]]; then
    #   Archlinux stuff will go here
    #   alias xc="xclip -selection clipboard ; xclip -o -selection clipboard"
    #   alias xp="xclip -o -selection clipboard"
else
    # MacOS aliases
    alias python3.8="/usr/local/Cellar/python@3.8/3.8.6_1/bin/python3.8"
    alias pip3.8="/usr/local/Cellar/python@3.8/3.8.6_1/bin/pip3.8"
fi

#####################
# FANCY-CTRL-Z      #
#####################
function fg-fzf() {
    job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job
}
function fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER=" fg-fzf"
        zle accept-line -w
    else
        zle push-input -w
        zle clear-screen -w
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

#####################
# FZF SETTINGS      #
#####################
# --bind 'ctrl-v:execute(code {+})'
# --bind 'ctrl-e:execute(nvim {} < /dev/tty > /dev/tty 2>&1)' > selected
export FZF_DEFAULT_OPTS="
--color='16,border:15'
--ansi
--layout=default
--info=inline
--height=50%
--multi
--preview-window=right:50%
--preview-window=sharp
--preview-window=cycle
--preview '([[ -f {} ]] && (bat --style=numbers --color=always --theme=base16 --line-range :500 {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
--prompt='λ -> '
--pointer='|>'
--marker='✓'
"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER=';;'

#####################
# P10K SETTINGS     #
#####################
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

