#!/bin/sh

pkill mbsync
(mbsync -aV) &
pkill -SIGRTMIN+11 i3blocks
wait
pkill -SIGRTMIN+11 i3blocks
