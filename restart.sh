#/bin/bash

# Restart i3wm and its entangled crew

notify-send -a "Conforg" "Restarting i3... 🙏"

# Reload i3wm (wait for 1s)
i3-msg restart
sleep 1

NOTI_TIMEOUT=1000

# Reload dunst
killall dunst
i3-msg "exec --no-startup-id dunst"
notify-send -t $NOTI_TIMEOUT -a "Conforg" "i3 restarted, reloading stuff.. 😎"

# Reload nextcloud
# Fix the (bug) lost tray icon after restarting i3
notify-send -t $NOTI_TIMEOUT -a "Conforg" "Reloading Nextcloud client.. ⛳"
killall nextcloud
i3-msg "exec --no-startup-id nextcloud"

# Reload emacs daemon
notify-send -t $NOTI_TIMEOUT -a "Conforg" "Reloading Emacs daemon.. ⛳"
emacs-daemon-shutdown
i3-msg "exec --no-startup-id LC_CTYPE=zh_CN.UTF-8 emacs --daemon"

# Reload KDEConnect
notify-send -t $NOTI_TIMEOUT -a "Conforg" "Reloading KDEConnect.. ⛳"
killall kdeconnect-indi
i3-msg "exec --no-startup-id kdeconnect-indicator"

# Reload compton
notify-send -t $NOTI_TIMEOUT -a "Conforg" "Reloading Compton.. ⛳"
i3-msg killall compton
i3-msg "exec --no-startup-id compton -b"

# Reset wallpaper
feh --randomize --bg-scale /usr/share/backgrounds/*

notify-send -t $NOTI_TIMEOUT -a "Conforg" "Reload finished. 😎" "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
