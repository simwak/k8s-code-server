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

# Configure Kube Config
kubectl config set-cluster local --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials service-account
kubectl config set-credentials service-account --token=$(cat "/var/run/secrets/kubernetes.io/serviceaccount/token")
kubectl config set-context local --user=service-account --namespace=$NAMESPACE
kubectl config use-context local

dumb-init fixuid -q /usr/bin/code-server --bind-addr 0.0.0.0:8080 .