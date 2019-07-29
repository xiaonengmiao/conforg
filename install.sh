#!/bin/bash

OPTIND=1

DPI=100
VERBOSE=0
QUIET=0
LOGFILE=/tmp/conforg.log
DEFAULT_CONFORG_DIR=$HOME/.conforg
GITIGNORE_IN=./contrib/gitignore
GITIGNORE_OUT=$HOME/.gitignore_global
PASSWORD_STORE=true
ALARM_SOUND=clock-chimes-daniel_simon.wav
MINIMAL_INSTALL=false

INSTALL_ARGS="$*"

function show_help() {
  echo "-v Show detailed logs"
  echo "-q Supress all warnings, also unset -v"
  echo "-d <DPI> Set the DPI value in .Xresources (default to be 100)."
  echo "         A rule of thumb is to set this value such that 11pt font looks nice."
  echo "-f <file> Set log file"
  echo "-c <path> Set conforg path"
  echo "-g <file> Set global gitignore file"
  echo "-a <file> Set which alarm sound to use under contrib/sounds"
  echo "-p Plain install (do not set up credentials with pass)"
  echo "-m Minimal install (for servers, without additional bells and whistles)"
}

while getopts "h?vd:a:f:qc:g:pm" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    v)
      VERBOSE=1;;
    a)
      ALARM_SOUND=$OPTARG;;
    d)
      DPI=$OPTARG;;
    f)
      LOGFILE=$OPTARG;;
    q)
      QUIET=1;;
    c)
      DEFAULT_CONFORG_DIR=$OPTARG;;
    g)
      GITIGNORE_OUT=$OPTARG;;
    p)
      PASSWORD_STORE=false;;
    m)
      MINIMAL_INSTALL=true;;
    : )
      echo "Option -"$OPTARG" requires an argument." >&2
      exit 1;;
  esac
done

if [[ $QUIET != 0 ]]; then
  VERBOSE=0
fi

function box_out() {
  if [[ $VERBOSE == 0 ]]; then
    return
  fi
  local s="$*"
  tput setaf 3
  echo " -${s//?/-}-
| ${s//?/ } |
| $(tput setaf 4)$s$(tput setaf 3) |
| ${s//?/ } |
 -${s//?/-}-"
  tput sgr 0
}

function box_warn()
{
  if [[ $QUIET != 0 ]]; then
    return
  fi
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 5
  echo "  **${b//?/*}**"
  for l in "${s[@]}"; do
    printf '  * %s%*s%s *\n' "$(tput setaf 6)" "-$w" "$l" "$(tput setaf 5)"
  done
  echo "  **${b//?/*}**"
  tput sgr 0
}

function finish_up()
{
  # Save the command only if the installer proceeds this far
  echo $INSTALL_ARGS > $HOME/.config/conforgrc

  box_out "Almost done: manual setup required."
  if [[ $QUIET != 0 ]]; then
    exit 0
  else
    echo "- To finish setting up Tmux plugins, open up tmux and hit 'prefix + I'."
    echo "- To finish setting up Neovim plugins, open up neovim and run ':PlugInstall'."
    echo "- To finish setting up, open up zsh and do the zkbd setup (preferably in a true terminal)."
  fi

  exit 0
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

if [[ $VERBOSE != 0 ]]; then
  echo "+ Running on $PLATFORM"
fi

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
  if [[ $VERBOSE != 0 ]]; then
    set -x;
  fi
  mkdir -p $HOME/.emacs.d;
  mkdir -p $HOME/.mozilla;
  mkdir -p $HOME/.config;

  mkdir -p $HOME/.config/conforg;

  mkdir -p $HOME/.config/fontconfig;
  mkdir -p $HOME/.config/nvim;
  mkdir -p $HOME/.config/nvim/autoload/;
  mkdir -p $HOME/.config/nvim/syntax/;
  mkdir -p $HOME/.config/i3;
  mkdir -p $HOME/.config/i3blocks;
  mkdir -p $HOME/.config/dunst;
  mkdir -p $HOME/.config/kitty;
  mkdir -p $HOME/.config/zathura;

  mkdir -p $HOME/.config/khard;
  mkdir -p $HOME/.config/vdirsyncer;

  mkdir -p $HOME/.config/ranger;
  mkdir -p $HOME/.config/ranger/colorschemes/;

  mkdir -p $HOME/.config/mpd;
  mkdir -p $HOME/.config/mpd/playlists;

  mkdir -p $HOME/.config/systemd;
  mkdir -p $HOME/.config/systemd/user;

  mkdir -p $HOME/.config/newsboat;

  mkdir -p $HOME/.tmux;
  mkdir -p $HOME/.tmux/plugins;

  mkdir -p $HOME/.task;
)

box_out "Parsing conf.org.."
echo "If the process hangs, try openning a standalone emacs session to debug."
echo " (Possibly need to set encoding / install plugins.)"
emacs -Q --batch \
  --eval '(require (quote org))' \
  --eval '(org-babel-tangle-file "conf.org")' \
  >> $LOGFILE 2>&1
if [[ $VERBOSE != 0 ]]; then
  tail -n 1 $LOGFILE
  echo "See $LOGFILE for details"
fi

box_out "Adding final touches.."

# Vim-plug
cp contrib/vim-plug/plug.vim $HOME/.config/nvim/autoload/plug.vim

# Vim-pyopencl
cp contrib/vim-pyopencl/pyopencl.vim $HOME/.config/nvim/syntax/pyopencl.vim

# TPM (auto update if exists)
TPMPATH=$HOME/.tmux/plugins/tpm
if ! [ -d $TPMPATH/.git ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm \
  >> $LOGFILE 2>&1
else
  (cd $TPMPATH && git pull >> $LOGFILE 2>&1 && cd - >> $LOGFILE 2>&1)
fi;

# cli-utils
if [ -L $HOME/cli-utils ]; then
  rm -f $HOME/cli-utils
fi
ln -sf $DEFAULT_CONFORG_DIR/contrib/cli-utils $HOME/cli-utils

if [[ $VERBOSE != 0 ]]; then
  set +o xtrace
  echo "+ Adding contents to .gitignore_global"
fi

# .gitignore_global
cat $GITIGNORE_IN/Global/*.gitignore >> $GITIGNORE_OUT
cat $GITIGNORE_IN/*.gitignore >> $GITIGNORE_OUT

# Python files are not to be ignored (e.g. __init__.py)
echo "!*.py" >> $GITIGNORE_OUT

# Ranger file glyphs
cd contrib/ranger_devicons && make install \
  >> /tmp/conforg.log 2>&1
cd ../..

# Ranger color theme
cd contrib/ranger_colortheme && cat ranger_colortheme_custom.py \
  > $HOME/.config/ranger/colorschemes/custom.py
cd ../..

# Jupyter notebook config
# requires: jupyterlab, jupytext
cd contrib/jupyter-nbconfig && sh ./setup.sh
cd ../..

# Ranger scope.sh
# chmod +x ~/.config/ranger/scope.sh

##################################################################
# minimal install ends here
##################################################################
if $MINIMAL_INSTALL; then
  box_warn "Warning: This is a minimal install, skipping extra setups."
  echo "+ Finishing up"
  finish_up
fi

mkdir -p $HOME/Contacts;

# update X server database
$SED_BIN -i "/Xft.dpi/c\Xft.dpi:\ $DPI" $HOME/.Xresources  
if ! [ -x "$(command -v xrdb)" ]; then
  echo 'Warning: .Xresources is not activated.' >&2
  if [[ $VERBOSE != 0 ]]; then
    set -o xtrace
  fi
else
  if [[ $VERBOSE != 0 ]]; then
    set -o xtrace
  fi
  xrdb ~/.Xresources
fi

# Alarm sound
cp -f contrib/sounds/$(ALARM_SOUND).wav $HOME/.alarm.wav

# find-cursor
cd contrib/find-cursor && make \
  >> /tmp/conforg.log 2>&1
cd ../..

if $PASSWORD_STORE; then
  # isync
  if [[ $VERBOSE != 0 ]]; then
    echo "+ Setting up isync (IMAP client)"
  fi
  pass show WXYZG/Email-mkmaildirs > $HOME/.mkmaildirs_commands.tmp 2>>$LOGFILE
  source $HOME/.mkmaildirs_commands.tmp
  rm $HOME/.mkmaildirs_commands.tmp
  pass show WXYZG/Email-mbsyncrc > $HOME/.mbsyncrc 2>>$LOGFILE
fi

# use openssl's ca list (brew install openssl)
if [[ $PLATFORM == 'mac' ]]; then
  $SED_BIN -i '/CertificateFile/c\CertificateFile /usr/local/etc/openssl/cert.pem' $HOME/.mbsyncrc
fi

if [ -d $HOME/Mail ]; then
  box_warn "Warning: Mail directory already exists."\
    "Updating .mbsyncrc could cause errors for future syncs." \
    "Remove \$HOME/.mbsync/ for a clean re-sync."
fi
if [ -d $HOME/.mbsync ]; then
  box_warn "Warning: .mbsync directory already exists." \
    "Updating .mbsyncrc could cause errors for future syncs." \
    "Remove \$HOME/.mbsync/ for a clean re-sync."
fi

if $PASSWORD_STORE; then
  # msmtp
  if [[ $VERBOSE != 0 ]]; then
    echo "+ Setting up msmtp (SMTP client)"
  fi
  pass show WXYZG/Email-msmtprc > $HOME/.msmtprc 2>>$LOGFILE
  chmod 600 $HOME/.msmtprc

  # org2blog
  pass show WXYZG/Blog-org2blogrc > $HOME/.emacs.d/org2blogrc.el

  # mu4e
  if [[ $VERBOSE != 0 ]]; then
    echo "+ Setting up mu4e"
  fi
  pass show WXYZG/Email-mu4erc > $HOME/.emacs.d/mu4e-config.el 2>>$LOGFILE

  # org-caldav
  if [[ $VERBOSE != 0 ]]; then
    echo "+ Setting up org-caldav"
  fi
  pass show WXYZG/GTD-org-caldav > $HOME/.emacs.d/org-caldav-config.el 2>>$LOGFILE
fi

# emojisel
rm -f $HOME/.config/emoji_list
cp contrib/emojisel/emoji_list $HOME/.config/emoji_list

# patch for MacOS (brew install mu --with-emacs)
if [[ $PLATFORM == 'mac' ]]; then
  $SED_BIN -i 's@/usr/share/emacs/site-lisp/@/usr/local/share/emacs/site-lisp/mu/@g' $HOME/.emacs.d/init.el
fi

# newsboat feeds
if [[ $VERBOSE != 0 ]]; then
  echo "+ Setting up newsboat"
fi
pass show WXYZG/RSS-newsboat-feeds >> $HOME/.config/newsboat/config

# Basic i3blocks config
cat $HOME/.config/i3blocks/config-header > $HOME/.config/i3blocks/config
cat $HOME/.config/i3blocks/config-nounicode >> $HOME/.config/i3blocks/config

# Taskwarrior Theme
if [[ $PLATFORM == 'mac' ]]; then
  TASK_THEME=/usr/local/share/doc/task/rc/solarized-light-256.theme
else
  TASK_THEME=/usr/share/doc/task/rc/solarized-light-256.theme
fi
$SED_BIN -i "s@TASKWARRIOR_COLOR_THEME@$TASK_THEME@g" $HOME/.taskrc

# Reload systemd user units
systemctl --user daemon-reload

# Enable time-based color switching
systemctl --user enable night-and-day.timer
systemctl --user start night-and-day.timer

# Enable auto updates of RSS feeds
systemctl --user enable newsboat-update.timer
systemctl --user start newsboat-update.timer

HAS_TASKD_SERVER=false
if $PASSWORD_STORE; then
  # Taskwarrior sync
  if [[ $VERBOSE != 0 ]]; then
    echo "+ Setting up connection with Taskwarrior server"
  fi
  AEHOME=$(echo $HOME | $SED_BIN 's@\/@\\\\\\\/@g')
  $SED_BIN -i "s@ABSOLUTE_ESCAPED_HOME_DIR@$AEHOME@g" $HOME/.taskrc
  if ! [ -x "$(command -v pass)" ]; then
    echo 'Warning: .taskrc is not setup with server sync (lacking credentials).' >&2
  else
    $SED_BIN -i "s@TASKD_SERVER_ADDR@$(pass WXYZG/TaskwarriorServerAddress)@g" $HOME/.taskrc
    $SED_BIN -i "s@TASKD_SERVER_USER_KEY@$(pass WXYZG/TaskwarriorUserUUID-xywei)@g" $HOME/.taskrc
    pass WXYZG/TaskwarriorServerCertificate > $HOME/.task/ca.cert.pem 2>>$LOGFILE
    pass WXYZG/TaskwarriorUserCertificate-xywei > $HOME/.task/xywei.cert.pem 2>>$LOGFILE
    pass WXYZG/TaskwarriorUserKey-xywei > $HOME/.task/xywei.key.pem 2>>$LOGFILE
    HAS_TASKD_SERVER=true
  fi
fi

if $HAS_TASKD_SERVER; then
  box_out "Syncing Tasks"
  task sync >> $LOGFILE 2>&1
fi

# Lastly, do an inital setup of color scheme
$HOME/cli-utils/set_dynamic_colors

finish_up
