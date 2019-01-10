#/bin/bash

# Refresh the install with previous configs

CONFORG_RC=$HOME/.config/conforgrc
CONFORG_DIR=$HOME/.conforg

if [ -f $CONFORG_RC ]; then
  ARGS=$(<$CONFORG_RC)
else
  ARGS=""
fi

notify-send -u critical -a "Conforg" "Start refreshing configs... 🙏" "It shall be done in a few seconds, fingers crossed."
cd $CONFORG_DIR
eval "bash install.sh $ARGS"

# Reload i3wm (wait for 1s)
i3-msg restart
sleep 1

# Reload dunst
# Assuming i3 config has: exec_always --no-startup-id dunst
killall dunst
notify-send -a "Conforg" "Configs refreshed. 😎" "Things that may need manual setup: TPM, vim-plug, zkbd."

# Reload nextcloud
# Fix the (bug) lost tray icon after restarting i3
killall nextcloud
i3-msg exec nextcloud
