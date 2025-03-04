########################################
# Install OS Specific common packages
########################################
if [ "$(uname)" = 'Darwin' ]; then
  echo "Setup MacOS specific packages."

  # iterm2 settings
  rm -rdf ~/dotfiles/terminal-app
  cd ~/dotfiles
  git clone https://github.com/dracula/terminal-app terminal-app
  git clone https://github.com/dracula/iterm.git iterm
  curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
  echo "Finish MacOS specific setup."
elif [ "$(uname)" = 'Linux' ]; then
  echo "Setup Linux specific packages."
  if [ "$(command -v apt)" ]; then
    echo "Start apt based setup."
    apt -y update
    export DEBIAN_FRONTEND=noninteractive
    export TZ="Asia/Tokyo"
    apt install -y tzdata
    ln -fs /usr/share/zoneinfo/$TZ/ /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata

    apt -y upgrade

    apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev \
      libreadline-dev libsqlite3-dev libopencv-dev tk-dev libz-dev git curl
  fi
fi

########################################
# Install brew package manager
########################################
echo "Install brew."
if [ ! "$(command -v brew)" ]; then
  export NONINTERACTIVE=1
  echo "Homebrew is not installed, Installing homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ "$(uname)" = "Darwin" ]; then
    echo 'export PATH=$PATH:/opt/homebrew/bin' >>~/.zshrc
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
  elif [ "$(uname)" = "Linux" ]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

########################################
# Set zsh as default shell
########################################
echo "Check default shell."
if [ ! "$(command -v zsh)" ]; then
  brew install zsh
  chsh -s "$(which zsh)"
fi
source ~/.zshrc

########################################
# Install common packages
########################################
echo "Install common packages with brew."
brew update
brew upgrade
brew bundle install
source ~/.zshrc

# TODO: node:
npm install -g commitzen cz-git

# Install cod
cd ~
git clone https://github.com/dim-an/cod.git
cd cod
go build
cd ~

# Install tmux plugin manager
if [ ! -e ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

########################################
# common dotfile settings
########################################
echo "Link dotfiles."
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/vim ~/.vim
ln -s ~/dotfiles/.ideavimrc .ideavimrc
mkdir -p ~/.config
ln -s ~/dotfiles/nvim ~/.config/nvim
echo 'source ~/dotfiles/.zshrc' >>~/.zshrc
