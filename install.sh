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

box_out "Detecting your OS.."

PLATFORM='unknown'
UNAMESTR=`uname`
if [[ "$UNAMESTR" == 'Linux' ]]; then
   PLATFORM='linux'
elif [[ "$UNAMESTR" == 'Darwin' ]]; then
   PLATFORM='mac'
elif [[ "$UNAMESTR" == 'FreeBSD' ]]; then
   PLATFORM='freebsd'
fi

echo "+ Running on $PLATFORM"

SED_BIN=sed
if [[ $PLATFORM == 'mac' ]]; then
  if ! [ -x "$(command -v gsed)" ]; then
    echo 'Error: GNU sed is necessary for the setup. Installing gsed with homebrew is recommended.' >&2
    exit 1
  else
    SED_BIN=gsed
    echo '+ Found gsed'
  fi
fi

box_out "Setting up directory structure.."
# in a subshell
(
  set -x;
  mkdir -p $HOME/.emacs.d;
  mkdir -p $HOME/.mozilla;
  mkdir -p $HOME/.config;

  mkdir -p $HOME/.config/nvim;
  mkdir -p $HOME/.config/nvim/autoload/;
  mkdir -p $HOME/.config/i3;

  mkdir -p $HOME/.tmux;
  mkdir -p $HOME/.tmux/plugins;

  mkdir -p $HOME/.task
  mkdir -p $HOME/Contacts
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
cp contrib/vim-plug/plug.vim $HOME/.config/nvim/autoload/plug.vim

# TPM (auto update if exists)
TPMPATH=$HOME/.tmux/plugins/tpm
if ! [ -d $TPMPATH/.git ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
else
  cd $TPMPATH && git pull && cd -
fi;

# cli-utils
if [ -L $HOME/cli-utils ]; then
  rm -f $HOME/cli-utils
fi
ln -sf $DEFAULT_CONFORG_DIR/contrib/cli-utils $HOME/cli-utils

set +o xtrace
echo "+ Adding contents to .gitignore_global"

# .gitignore_global
cat $GITIGNORE_IN/Global/*.gitignore >> $GITIGNORE_OUT
cat $GITIGNORE_IN/*.gitignore >> $GITIGNORE_OUT

# Python files are not to be ignored (e.g. __init__.py)
echo "!*.py" >> $GITIGNORE_OUT

# isync
echo "+ Setting up isync (IMAP client)"
pass show WXYZG/Email-mkmaildirs > $HOME/.mkmaildirs_commands.tmp
source $HOME/.mkmaildirs_commands.tmp
rm $HOME/.mkmaildirs_commands.tmp
pass show WXYZG/Email-mbsyncrc > $HOME/.mbsyncrc

# msmtp
echo "+ Setting up msmtp (SMTP client)"
pass show WXYZG/Email-msmtprc > $HOME/.msmtprc

# Taskwarrior Theme
if [[ $PLATFORM == 'mac' ]]; then
  TASK_THEME=/usr/local/share/doc/task/rc/solarized-light-256.theme
else
  TASK_THEME=/usr/share/doc/task/rc/solarized-light-256.theme
fi
$SED_BIN -i "s@TASKWARRIOR_COLOR_THEME@$TASK_THEME@g" $HOME/.taskrc

# Taskwarrior sync
echo "+ Setting up connection with Taskwarrior server"
AEHOME=$(echo $HOME | $SED_BIN 's@\/@\\\\\\\/@g')
HAS_TASKD_SERVER=false
$SED_BIN -i "s@ABSOLUTE_ESCAPED_HOME_DIR@$AEHOME@g" $HOME/.taskrc
if ! [ -x "$(command -v pass)" ]; then
  echo 'Warning: .taskrc is not setup with server sync (lacking credentials).' >&2
else
  $SED_BIN -i "s@TASKD_SERVER_ADDR@$(pass WXYZG/TaskwarriorServerAddress)@g" $HOME/.taskrc
  $SED_BIN -i "s@TASKD_SERVER_USER_KEY@$(pass WXYZG/TaskwarriorUserUUID-xywei)@g" $HOME/.taskrc
  pass WXYZG/TaskwarriorServerCertificate > $HOME/.task/ca.cert.pem
  pass WXYZG/TaskwarriorUserCertificate-xywei > $HOME/.task/xywei.cert.pem
  pass WXYZG/TaskwarriorUserKey-xywei > $HOME/.task/xywei.key.pem
  HAS_TASKD_SERVER=true
fi

if $HAS_TASKD_SERVER; then
  box_out "Syncing Tasks"
  task sync
fi

box_out "Almost done: manual setup required."
echo "- To finish setting up Tmux plugins, open up tmux and hit 'prefix + I'."
echo "- To finish setting up Neovim plugins, open up neovim and run ':PlugInstall'."
echo "- To finish setting up, open up zsh and do the zkbd setup (preferably in a true terminal)."

