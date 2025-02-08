FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 

# 1. Install basic environment (time, locale, zsh)
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN apt update && apt upgrade -y && apt install -y tzdata language-pack-ja locales zsh;

ENV SHELL /usr/bin/zsh
RUN zsh
#set default shell to zsh
RUN chsh -s /bin/zsh
SHELL ["/bin/zsh", "-c"]

RUN locale-gen ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8
ENV  NONINTERACTIVE=1

# 2. Install basic tools.
RUN apt install -y build-essential cmake git wget curl;
WORKDIR /root
# 3. Install dev environment.
RUN  git clone https://github.com/underfirst/dotfiles.git
WORKDIR /root/dotfiles
RUN /bin/zsh -c "cd /root/dotfiles; ./setup.sh"
RUN source ~/.zshrc && brew install uv
