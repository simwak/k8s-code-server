FROM ubuntu:18.04

# Forked of https://github.com/gashirar/code-server-on-kubernetes

RUN apt-get update && apt-get install -y \
    openssl \
    net-tools \
    git \
    locales \
    sudo \
    dumb-init \
    vim \
    curl \
    wget \
    bash-completion \
    python3

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN ARCH=amd64 && \
    curl -sSL "https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

RUN CODE_SERVER_VERSION=3.3.1 && \
    curl -sSOL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb && \
    sudo dpkg -i code-server_${CODE_SERVER_VERSION}_amd64.deb

## kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

## helm
RUN HELM_VERSION=v3.0.0 && \
    mkdir /tmp/helm && \
    curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o /tmp/helm/helm.tar.gz && \
    tar xvf /tmp/helm/helm.tar.gz -C /tmp/helm/ && \
    chmod +x /tmp/helm/linux-amd64/helm && \
    sudo -S mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm && \
    rm -r /tmp/helm

RUN locale-gen en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN chmod g+rw /home

## User account
RUN adduser --disabled-password --gecos '' coder && \
    adduser coder sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers;

# Add needed files
ADD README.md /home/coder/README.md
ADD init.sh /home/init.sh

RUN echo "source <(kubectl completion bash)" >> /home/coder/.bashrc && \
    echo 'export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/coder/.bashrc

RUN chown -R coder:coder /home/coder

# Move home directory to tmp for move back after pvc is mounted there
RUN mv /home/coder /home/codertmp

# Change user
USER coder

ENV PASSWORD=${PASSWORD:-P@ssw0rd}

WORKDIR /home/coder

EXPOSE 8080

ENTRYPOINT ["sh", "/home/init.sh"]