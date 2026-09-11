FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

SHELL ["/bin/bash", "-c"]
WORKDIR /root/dotfiles

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Asia/Tokyo"
ENV PATH="/root/.local/bin:/root/.local/share/mise/shims:$PATH"

# curl and certificates are needed to bootstrap mise itself. The remaining
# system packages are declared in mise/config.linux.toml.
RUN apt-get update && \
  apt-get install -y --no-install-recommends curl ca-certificates bash && \
  rm -rf /var/lib/apt/lists/*

RUN curl https://mise.run | sh

COPY .miserc.toml /root/dotfiles/.miserc.toml
COPY mise/ /root/dotfiles/mise/
COPY scripts/ /root/dotfiles/scripts/
COPY configs/ /root/dotfiles/configs/
COPY nvim/ /root/dotfiles/nvim/
COPY .tmux.conf .vimrc .zshrc /root/dotfiles/

RUN cd /root/dotfiles && \
  mise trust && \
  mise run setup-docker

WORKDIR /app
