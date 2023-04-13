#!/usr/bin/env zsh

set -e

APP_DIR="/Applications"
DEV_DIR="$HOME/Development"
DOTFILES_DIR="$DEV_DIR/dotfiles"
WORKFLOWS_DIR="$DOTFILES_DIR/workflows"
MISC_BIN_LOC="/usr/local/bin"

# brew_packages=(bat cmake docker ffmpeg git htop mactex neofetch ninja node nmap python3 qlcolorcode qlimagesize qlmarkdown qlstephen quicklook-csv quicklook-json shellcheck thefuck vim wget zsh)
homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
omz_url="https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
iterm_url="https://iterm2.com/downloads/stable/latest"

function install_pip() {
  sudo easy_install pip
}

function install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  /opt/homebrew/bin/brew shellenv
  brew update && brew upgrade
}

function install_brew_packages() {
  echo "Installing Homebrew packages..."
  while read brew_package; do
    echo "Brew-installing $brew_package"
    brew install $brew_package
  done <$DOTFILES_DIR/brew_manifest
  echo "Finished installing Homebrew packages!"
}

function install_cask_packages() {
  echo "Installing Cask packages..."
  brew tap "homebrew/cask"
  for item in "${cask_packages[@]}"; do
    echo "Cask-installing $item"
    brew install $item
  done
  echo "Finished installing Cask packages!"
}

function install_oh_my_zsh() {
  curl -L http://install.ohmyz.sh | sh
  echo "Installing Zsh Syntax Highlighting..."
  git clone git@github.com:zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo "Finished installing OMZ + Zsh Syntax Highlighting"
}

function install_powerline_fonts() {
  echo "Cloning Powerline patched fonts:"
  git clone git@github.com:powerline/fonts $DOTFILES_DIR/fonts
  echo "Installing..."
  $DOTFILES_DIR/fonts/install.sh
  echo "Installation complete. Performing cleanup:"
  rm -rf $DOTFILES_DIR/fonts
  echo "Done."
}

function install_iterm() {
  curl -Lq $iterm_url > iterm.zip
  unzip -q iterm.zip
  mv iTerm.app/ $APP_DIR/
  rm iterm.zip
}

function setup_configs() {
  echo "Copying dotfiles to $HOME..."
  yes | cp -rf $DOTFILES_DIR/.[^.][^git]* $HOME
}

function setup_global_gitconfig() {
  echo "Setting up global git config..."
  if [ -z $(git config --global user.name) ]; then
    echo "A global git config may already be in place. Skipping global git config setup."
  else
    read -p "Please enter your GitHub username: " user_name
    read -p "Please enter your GitHub email: " user_email

    git config --global user.name "$user_name"
    git config --global user.email "\"$user_email\""
  fi
}

function install_packages() {
  install_brew_packages
}

function already_installed() {
  echo "$1 already installed."
}

# Manual installation, because brew-installation of pure appears to be broken on
# Apple Silcon Macs, despite "resolved" issues indicating otherwise.
function install_pure_theme() {
  mkdir -p "$HOME/.zsh"
  git clone git@github.com:sindresorhus/pure.git "$HOME/.zsh/pure"
}

function add_automator_scripts() {
  echo "Copying automator scripts..."
  cp -R $WORKFLOWS_DIR/*.workflow ~/Library/Services/
  echo "Finished copying automator scripts!"
  echo "Configuring keyboard shortcuts for 'System Prefs > Keyboard > Shortcuts > Services'..."
  cp $DOTFILES_DIR/pbs.plist ~/Library/Preferences/
  echo "Finished configuring keyboard shortcuts!"
  echo "Reloading System Preferences configuration."
  killall cfprefsd && killall Finder
  echo "Automated scripts are now mapped to keyboard shortcuts!"
}

function check_and_conditionally_install() {
  # Check for pip, disabling possibly-unnecessary, error-filled step for now
  # command -v pip >/dev/null 2>&1 && already_installed "Pip" || { echo >&2 "Installing pip..."; install_pip; }

  # Check for Homebrew
  command -v brew >/dev/null 2>&1 && \
    already_installed "Homebrew" || \
    { echo >&2 "Installing Homebrew..."; install_homebrew; }

  # Install Homebrew, Cask packages
  install_packages

  setup_global_gitconfig
  add_automator_scripts

  # Install OMZ
  if [ -d $HOME/.oh-my-zsh ]; then
    already_installed "Oh My Zsh"
  else
    echo  "Installing Oh My Zsh..."
    install_oh_my_zsh
  fi

  # Install Powerline patched fonts (for some OMZ themes)
  if [[ $(system_profiler SPFontsDataType | grep Powerline) ]]; then
    already_installed "Powerline Fonts"
  else
    install_powerline_fonts
  fi

  # Set up shell profile
  setup_configs

  if [ -d $APP_DIR/iTerm.app ]; then
    already_installed "iTerm"
  else
    install_iterm
    echo "Configuring iTerm..."
    defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string $DOTFILES_DIR
    defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
  fi

  # Install Pure OMZ theme
  if [ -d $HOME/.zsh/pure/ ]; then
    already_installed "pure OMZ theme"
  else
    install_pure_theme
  fi

  # Not needed by macOS 11+
  echo "Ensuring zsh is registered..."
  if ! $(grep -q $(which zsh) /etc/shells); then
    echo "Adding zsh to /etc/shells..."
    sudo bash -c 'echo $(which zsh) >> /etc/shells'
  else
    echo "zsh is already in '/etc/shells.'"
  fi

  if $(echo $0 | grep zsh); then
    chsh -s $(which zsh)
  fi

  echo "You should be all set! Get hacking!"
}

# Entry point is down here!

# Prep misc. binary location
if [ ! -d $MISC_BIN_LOC ]; then
  echo "Creating '$MISC_BIN_LOC'. You will be prompted for elevated perms."
  sudo mkdir $MISC_BIN_LOC
fi

check_and_conditionally_install
