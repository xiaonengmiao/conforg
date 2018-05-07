#!/bin/bash

emacs -Q --batch --eval '(require (quote org))' \
  --eval '(org-babel-tangle-file "conf.org")'
