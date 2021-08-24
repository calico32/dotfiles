#!/bin/fish

[ (test ps a | grep "awesome\$" | wc -l) -gt 1 ] && exit

set awesomepid (ps a | grep "xinit.*xinitrc.*:[0-9]" | awk '{gsub(/^ +| +$/,"")} {print $1}')
set existing (cat "$XDG_RUNTIME_DIR/awesome.pid")

if test $existing = $awesomepid >/dev/null 2>&1
    exit 1
end

echo "$awesomepid" >$XDG_RUNTIME_DIR/awesome.pid


# pulseaudio -k; pulseaudio -D; sleep 0.5; pulseaudio -k; pulseaudio -D

pidof nextcloud || fish -c 'sleep 15 && nextcloud &' >/dev/null &

# notify-send -i /usr/share/icons/Paper/48x48/status/dialog-info.png "Autostart complete"
