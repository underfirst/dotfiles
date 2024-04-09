if [ "$(uname)" = 'Darwin' ]; then
  echo "Start MacOS specific setup."
  if [ ! "$(command -v brew)" ]; then
    echo "Homebrew is not installed, Installing homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo 'export PATH=$PATH:/opt/homebrew/bin' >> ~/.zshrc
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
  source ~/.zshrc

  brew update;
  brew upgrade;
  brew install cmake jq peco tmux htop sqlite3 \
               zlib fzf git mono autojump thefuck \
               openssl boost readline xz go watch tcl-tk pyenv navi;
  brew install cmd-eikana the-unarchiver rectangle appcleaner alfred \
               google-chrome thunderbird \
               pycharm iterm2 macvim bettertouchtool;

  # iterm2 settings
  rm -rdf ~/dotfiles/terminal-app
  cd ~/dotfiles;
  git clone https://github.com/dracula/terminal-app terminal-app
  git clone https://github.com/dracula/iterm.git iterm
  curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash


  git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts
  chmod 755 install.sh
  ./install.sh
  cd ..

  echo "Finish MacOS specific setup.";
elif [ "$(uname)" = 'Linux' ]; then
  if [ ! "$(command -v apt)" ]; then
    echo "Start apt based setup."
    apt -y update;
    apt -y upgrade;
    apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev \
                   libreadline-dev libsqlite3-dev libopencv-dev tk-dev git \
                   cmake jq peco tmux htop sqlite3 fzf autojump thefuck libz-dev \
                   golang-go
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv;
  elif [ ! "$(command -v yum)" ]; then
    echo "Start yum based setup."
    yum -y update;
    yum -y upgrade;
    # TODO: yum based install for pyenv, golang (for cod) and etc.
  fi
fi

echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

source ~/.zshrc
pyenv install 3.10.9
pyenv global 3.10.9
pyenv rehash

pip install --user --upgrade advance-touch jedi
cd ~
git clone https://github.com/dim-an/cod.git
cd cod
go build
cd ~
if [ ! -e ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# common dotfile settings
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/vim ~/.vim
ln -s ~/dotfiles/.ideavimrc .ideavimrc
mkdir -p ~/.config
ln -s ~/dotfiles/nvim ~/.config/nvim
