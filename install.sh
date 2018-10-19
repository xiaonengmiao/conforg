#!/bin/bash

LOGFILE=/tmp/conforg.log
DEFAULT_CONFORG_DIR=$HOME/.conforg

GITIGNORE_IN=./contrib/gitignore
GITIGNORE_OUT=$HOME/.gitignore_global

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

box_out "Greetings. Please make sure you cloned the repo under $DEFAULT_CONFORG_DIR."

box_out "Setting up directory structure.."
# in a subshell
(
  set -x;
  mkdir -p $HOME/.emacs.d;
  mkdir -p $HOME/.mozilla;
  mkdir -p $HOME/.config;

  mkdir -p $HOME/.config/nvim;
  mkdir -p /home/xywei/.config/nvim/autoload/;
  mkdir -p $HOME/.config/i3;

  mkdir -p $HOME/.tmux;
  mkdir -p $HOME/.tmux/plugins;
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
cd ../..

# Vim-plug
cp contrib/vim-plug/plug.vim /home/xywei/.config/nvim/autoload/plug.vim

# TPM (auto update if exists)
TPMPATH=$HOME/.tmux/plugins/tpm
if ! [ -d $TPMPATH/.git ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
else
  cd $TPMPATH && git pull && cd -
fi;

# cli-utils
ln -sf $DEFAULT_CONFORG_DIR/contrib/cli-utils $HOME/cli-utils

set +o xtrace
echo "+ Adding contents to .gitignore_global"

# .gitignore_global
cat $GITIGNORE_IN/Global/*.gitignore >> $GITIGNORE_OUT
cat $GITIGNORE_IN/*.gitignore >> $GITIGNORE_OUT

# Python files are not to be ignored (e.g. __init__.py)
echo "!*.py" >> $GITIGNORE_OUT

box_out "Almost done: manual setup required."
echo "- To finish setting up Tmux plugins, open up tmux and hit 'prefix + I'."
echo "- To finish setting up Neovim plugins, open up neovim and run ':PlugInstall'."
echo "- To finish setting up, open up zsh and do the zkbd setup (preferably in a true terminal)."
