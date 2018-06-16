#!/bin/bash

mkdir -p $HOME/.emacs.d
mkdir -p $HOME/.mozilla

emacs -Q --batch --eval '(require (quote org))' \
  --eval '(org-babel-tangle-file "conf.org")'

# update X server database
xrdb ~/.Xresources

# Ranger file glyphs
cd contrib/ranger_devicons && make install
