#!/bin/bash
PROXY=$1
sudo mkdir -p /usr/local/share/ca-certificates/extra
true | openssl s_client -connect $PROXY:443 2>/dev/null | openssl x509 > $PROXY.pem
sudo mv $PROXY.pem /usr/local/share/ca-certificates/extra/$PROXY.crt
sudo update-ca-certificates
