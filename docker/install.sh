#!/bin/bash -Eeu

apt install --yes ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
echo 'deb https://dl.bintray.com/dryzig/zig-ubuntu bionic main' | tee -a /etc/apt/sources.list
apt update
apt install --yes zig
