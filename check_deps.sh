#!/bin/sh

# List of commands that conforgs depends on
dependencies="
aplay
aspell
awk
cat
cc
convert
dunst
dmenu
flash_window
git
i3
i3blocks
emacs
fc-list
fzf
make
mpd
nvim
kitty
perl
python
rg
ranger
sed
systemctl
tmux
xrdb
zathura
zsh
"

optionals="
mbsync
msmtp
newsboat
pass
task
"

function invokable(){
  local app=$1
  hash $app 2>/dev/null
}

missing_deps=""

for cmd in $dependencies; do
    if invokable $cmd; then
      echo "Found $cmd"
    else
      echo "Can't find $cmd"
      missing_deps="$missing_deps $cmd"
    fi
done

if [[ $missing_deps != "" ]]; then
  echo ERROR: Missing necessary dependencies for conforg:
  echo "  $missing_deps"
  exit 1
fi

missing_opts=""

for cmd in $optionals; do
    if invokable $cmd; then
      echo "Found $cmd"
    else
      echo "Can't find $cmd"
      missing_opts="$missing_opts $cmd"
    fi
done

if [[ $missing_opts != "" ]]; then
  echo WARNING: Missing optional dependencies for conforg:
  echo "  $missing_opts"
  echo "Minimal install works, but some features will malfunction."
  exit 2
fi

echo "Congratulations! All deps have been found."
echo "
  Note that this is just a preliminary check on executable commands,
  you still have to take efforts to install correct fonts.
  "
