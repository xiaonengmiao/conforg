#!/bin/bash

mkdir -p $HOME/.emacs.d
mkdir -p $HOME/.mozilla
mkdir -p $HOME/.config

mkdir -p $HOME/.config/nvim
mkdir -p $HOME/.config/i3

emacs -Q --batch --eval '(require (quote org))' \
  --eval '(org-babel-tangle-file "conf.org")'

# update X server database
xrdb ~/.Xresources

# Ranger file glyphs
cd contrib/ranger_devicons && make install
