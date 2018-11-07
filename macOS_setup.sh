#!/usr/bin/env bash


DEV_FOLDER="$HOME/Development"
DOTFILES="$DEV_FOLDER/dotfiles"
WORKFLOWS="$DOTFILES/workflows"

brew_packages=(bat cmake docker ffmpeg git htop neofetch ninja node nmap python3 shellcheck thefuck vim wget zsh)
cask_packages=(mactex qlcolorcode qlimagesize qlmarkdown qlstephen quicklook-csv quicklook-json)
atom_url="https://github.com/atom/atom/releases/download/v1.20.0/atom-mac.zip"
homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
omz_url="https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
iterm_url="https://iterm2.com/downloads/stable/latest"

function install_pip() {
  sudo easy_install pip
}

function install_atom() {
  if ! [ -d /Applications/Atom.app ]; then
    curl -OL $atom_url
    echo "Unzipping Atom..."
    unzip -q atom-mac.zip
    echo "Moving Atom..."
    mv Atom.app/ /Applications/
    rm atom-mac.zip
  fi

  echo "Linking Atom CLI..."
  ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom
}

function install_atom_packages() {
  echo "Installing Atom packages..."
  apm install --packages-file $1
}

function install_homebrew() {
  /usr/bin/ruby -e "$(curl -fsSL $homebrew_url)"
  brew update && brew upgrade
}

function install_brew_packages() {
  echo "Installing Homebrew packages..."
  for item in "${brew_packages[@]}"; do
    echo "Brew-installing $item"
    brew install $item
  done
  echo "Finished installing Homebrew packages!"
}

function install_cask_packages() {
  echo "Installing Cask packages..."
  brew tap caskroom/cask
  for item in "${cask_packages[@]}"; do
    echo "Cask-installing $item"
    brew cask install $item
  done
  echo "Finished installing Cask packages!"
}

function install_oh_my_zsh() {
  curl -L http://install.ohmyz.sh | sh

  echo "Installing Pure theme..."
  npm install --global pure-prompt

  echo "Installing Zsh Syntax Highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  if [[ $(system_profiler SPFontsDataType | grep Powerline) ]]; then
    already_installed "It appears 'Powerline fonts'"
  else
    install_powerline_fonts
  fi
}

function install_powerline_fonts() {
  echo "Cloning Powerline patched fonts:"
  git clone git@github.com:powerline/fonts.git
  echo "Installing..."
  ./fonts/install.sh
  echo "Installation complete. Performing cleanup:"
  rm -rf fonts
  echo "Done."
}

function install_iterm() {
  curl -Lq $iterm_url > iterm.zip
  unzip iterm.zip
  mv iTerm.app/ /Applications/
  rm iterm.zip
}

function setup_configs() {
  echo "Copying dotfiles to $HOME..."
  yes | cp -rf $DOTFILES/.[^.][^git]* $HOME

  echo "Configuring iTerm..."
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string $DOTFILES
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
}
function setup_global_gitconfig() {
    read -p "Please enter your GitHub username: " user_name
    read -p "Please enter your GitHub email: " user_email

    git config --global user.name "$user_name"
    git config --global user.email "\"$user_email\""
}

function install_packages() {
  install_atom_packages "$DOTFILES/atom-package-list"
  install_brew_packages
  install_cask_packages
}

function already_installed() {
  echo "$1 is already installed."
}

function check_and_conditionally_install() {
  command -v pip >/dev/null 2>&1 && already_installed "Pip" || { echo >&2 "Installing pip..."; install_pip; }
  command -v atom >/dev/null 2>&1 && already_installed "Atom" || { echo >&2 "Installing & linking Atom..."; install_atom; }
  command -v brew >/dev/null 2>&1 && already_installed "Homebrew" || { echo >&2 "Installing Homebrew..."; install_homebrew; }

  install_packages
  setup_configs
  setup_global_gitconfig
  configure_atom
  add_automator_scripts

  if [ -d $HOME/.oh-my-zsh ]; then
    already_installed "Oh My Zsh"
  else
    echo  "Installing Oh My Zsh"
    install_oh_my_zsh
  fi

  if [ -d /Applications/iTerm.app ]; then
    already_installed "iTerm"
  else
    install_iterm
  fi

  if ! $(grep -q $(which zsh) /etc/shells); then
    echo "Adding zsh to /etc/shells..."
    sudo bash -c 'echo $(which zsh) >> /etc/shells'
  fi

  if $(echo $0 | grep zsh); then
    chsh -s $(which zsh)
  fi

  echo "You should be all set! Get hacking!"
}

# Note: Most likely *nix compatible. This may move
function configure_atom() {
    echo "Configuring Atom preferences..."
    cp $DOTFILES/config.cson ~/.atom/config.cson
    echo "Finished configuring Atom preferences!"
}

function add_automator_scripts() {
  echo "Copying automator scripts..."
  cp -R $WORKFLOWS/*.workflow ~/Library/Services/
  echo "Finished copying automator scripts!"
  echo "Configuring keyboard shortcuts for 'System Prefs > Keyboard > Shortcuts > Services'..."
  cp $WORKFLOWS/pbs.plist ~/Library/Preferences/
  echo "Finished configuring keyboard shortcuts!"
}

check_and_conditionally_install
