#!/bin/bash

mkdir -p $HOME/.emacs.d
mkdir -p $HOME/.mozilla

emacs -Q --batch --eval '(require (quote org))' \
  --eval '(org-babel-tangle-file "conf.org")'
