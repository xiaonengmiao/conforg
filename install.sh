#!/bin/bash

LOGFILE=/tmp/conforg.log

function box_out() {
  local s="$*"
  tput setaf 3
  echo " -${s//?/-}-
| ${s//?/ } |
| $(tput setaf 4)$s$(tput setaf 3) |
| ${s//?/ } |
 -${s//?/-}-"
  tput sgr 0
}

box_out "Setting up directory structure.."
# in a subshell
(
  set -x;
  mkdir -p $HOME/.emacs.d;
  mkdir -p $HOME/.mozilla;
  mkdir -p $HOME/.config;

  mkdir -p $HOME/.config/nvim;
  mkdir -p $HOME/.config/i3;
)

box_out "Parsing conf.org.."
emacs -Q --batch --eval '(require (quote org))' \
  --eval '(org-babel-tangle-file "conf.org")' \
  >> $LOGFILE 2>&1
tail -n 1 $LOGFILE
echo "See $LOGFILE for details"

box_out "Adding final touches.."
# update X server database
if ! [ -x "$(command -v xrdb)" ]; then
  echo 'Warning: .Xresources is not activated.' >&2
  set -o xtrace
else
  set -o xtrace
  xrdb ~/.Xresources
fi

# Ranger file glyphs
cd contrib/ranger_devicons && make install \
  >> /tmp/conforg.log 2>&1

