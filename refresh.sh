#/bin/bash

# Refresh the install with previous configs

CONFORG_RC=$HOME/.config/conforgrc
CONFORG_DIR=$HOME/.conforg

if [ -f $CONFORG_RC ]; then
  ARGS=$(<$CONFORG_RC)
else
  ARGS=""
fi

cd $CONFORG_DIR
eval "bash install.sh $ARGS"
