cat <<- EOF >> ~/.bashrc
# https://stackoverflow.com/a/3466183
get_env_type() {
  case "\$(uname -s)" in
    Darwin)
      echo 'MAC'
      ;;
    Linux)
      echo 'LINUX'
      ;;
    CYGWIN*|MSYS*|MINGW*)
      echo 'WINDOWS'
      ;;
    *)
      echo 'UNKNOWN'
      ;;
  esac
}

ENV_TYPE="\$(get_env_type)"

export EDITOR='/usr/bin/vim'
export HISTFILESIZE=1000

# BEGIN:Git-related shortcuts
# experimental: git subcommand completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
# install some useful git aliases
install_my_git_aliases() {
  git config --global alias.unadd 'restore --staged .'
  git config --global alias.uncommit 'reset --soft HEAD^'
}
# END:Git-related shortcuts

ghstatus() {
  curl -s 'https://www.githubstatus.com/index.json' | jq '.status'
}

pbsed() {
  pbpaste | sed -e "\$1" | pbcopy && pbpaste
}

pbed() {
  tempfile=\$(mktemp)

  pbpaste > "\$tempfile"

  if [[ -z "\$EDITOR" ]]; then
    vi "\$tempfile"
  else
    \$EDITOR "$tempfile"
  fi

  cat "\$tempfile" | pbcopy
}

# BEGIN:Prompt customization
alias is_rosetta='sysctl -n sysctl.proc_translated'
parse_git_branch() {
  git branch 2> /dev/null | awk '\$1=="*"{printf("[ "); for(i=2;i<=NF;i++){printf("%s ", $i)}; printf("] ")}'
}
if [[ \$(is_rosetta) -eq 1 ]]; then
  export PS1='\[\e[31;2m\]@\[\033[0m\] \w \[\e[34m\]\$(parse_git_branch)\[\e[0m\]\[\e[32m\]$\[\e[0m\] '
else
  export PS1='\w \[\e[34m\]\$(parse_git_branch)\[\e[0m\]\[\e[32m\]$\[\e[0m\] '
fi
PROMPT_DIRTRIM=3
# END:Prompt customization

# screw it
alias exti=exit
alias eixt=exit

if [[ "\$ENV_TYPE" = 'MAC' ]]; then
  TTS_COMMAND='say'
elif [[ "\$ENV_TYPE" = 'LINUX' ]]; then
  TTS_COMMAND='espeak' # Could also be termux-tts-speak in Termux
elif [[ "\$ENV_TYPE" = 'WINDOWS' ]]; then
  TTS_COMMAND='false'
fi

# Search for the last matching command on up-arrow, not just the last command
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Suppress the zsh thing. I'll move to zsh when I feel like it, thank you very much.
export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Set PATH, MANPATH, etc., for Homebrew.
# eval "\$(/opt/homebrew/bin/brew shellenv)"
eval "\$(/usr/local/bin/brew shellenv)"

export PATH="/Users/nchaverin/Library/Python/3.10/bin:\$PATH"

export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PACT_DO_NOT_TRACK=true
EOF
