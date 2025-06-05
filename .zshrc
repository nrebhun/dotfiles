source $HOME/.path
source $HOME/.env_vars
source $HOME/.aliases
source $HOME/.functions

# Plugins
plugins=(git zsh-autosuggestions zsh)

autoload -U promptinit; promptinit
prompt pure

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh