#!/usr/bin/env bash

# Clear out all previous attempts
sudo rm -rf "$HOME/git-rectify"

# Add new sources list
sudo cp -f sources.list /etc/apt/

# Get the dependencies for git, then get openssl
sudo apt-get update
sudo apt-get install build-essential fakeroot dpkg-dev -y
sudo mkdir -p "$HOME/git-rectify"
cd "$HOME/git-rectify"
sudo apt-get source git
sudo apt-get build-dep git -y
sudo apt-get install dialog -y
sudo apt-get install libcurl4-openssl-dev -y

sudo rm -rf $(find -mindepth 1 -maxdepth 1 -type d -name "git-*")
sudo dpkg-source -x $(find -mindepth 1 -maxdepth 1 -type f -name "*.dsc")

# We need to actually go into the git source directory
# find -type f -name "*.dsc" -exec dpkg-source -x \{\} \;
cd $(find -mindepth 1 -maxdepth 1 -type d -name "git-*")
pwd

# This is where we actually change the library from one type to the other.
sudo sed -i -- 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/' ./debian/control
# Compile time, itself, is long. Skips the tests. Do so at your own peril.
sudo sed -i -- '/TEST\s*=\s*test/d' ./debian/rules

# Build it.
sudo dpkg-buildpackage -rfakeroot -b

# Install
sudo find .. -type f -name "git_*64.deb" -exec sudo dpkg -i \{\} \;
