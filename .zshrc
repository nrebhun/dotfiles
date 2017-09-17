source $HOME/.env_vars
source $HOME/.path
source $HOME/.aliases
source $HOME/.functions

# Plugins
plugins=(git zsh-syntax-highlighting)

# Oh my ZSH
ZSH_THEME="refined"
source $ZSH/oh-my-zsh.sh

# PHPBrew
[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc
