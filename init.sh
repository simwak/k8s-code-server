#!/bin/bash

if [ -f "/home/coder/.config/code-server/config.yaml" ]; then
  # Only override code server config
  rm -f /home/coder/.config/code-server/config.yaml
  mv /home/codertmp/.config/code-server/config.yaml /home/coder/.config/code-server/config.yaml
else
  # Full init
  rm -rf /home/coder
  mkdir /home/coder
  cp -rp /home/codertmp/. /home/coder
fi

# Delete tmp home directory
rm -rf /home/codertmp

dumb-init fixuid -q /usr/bin/code-server --bind-addr 0.0.0.0:8080 .