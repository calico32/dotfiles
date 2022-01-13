
# dirs
set c "$HOME/.config"
set d "$HOME/dev"
set df "$HOME/.dotfiles"
set dl "$XDG_DATA_HOME/downloads"
set lb "$HOME/.local/bin"
set ls "$XDG_DATA_HOME"
set ll "$HOME/.local/lib"
set ub /usr/bin
set us /usr/share
set ul /usr/lib
set ulb /usr/local/bin
set uls /usr/local/share
set sa "$HOME/.steam/root/steamapps"
#set nv "/sys/bus/pci/devices/0000:01:00.0"
#set bl /sys/class/backlight/intel_backlight
set ssd /run/media/$USER/ssd

# vcs
abbr -- gcm git commit --message
abbr -- gs git status
abbr -- gsp git status --porcelain

# config
abbr -- caw nvim "$XDG_CONFIG_HOME/awesome"
abbr -- cfs nvim "$XDG_CONFIG_HOME/fish/config.fish"
abbr -- fsc cd "$XDG_CONFIG_HOME/fish"
abbr -- cen nvim "$XDG_CONFIG_HOME/fish/conf.d/environment.fish"
abbr -- cpc nvim "$XDG_CONFIG_HOME/picom/picom.conf"
abbr -- pcc cd "$XDG_CONFIG_HOME/picom"
abbr -- cdn nvim "$XDG_CONFIG_HOME/dunst/dunstrc"
abbr -- dnc cd "$XDG_CONFIG_HOME/dunst"
abbr -- cnv nvim "$XDG_CONFIG_HOME/nvim/init.vim"
abbr -- nvc cd "$XDG_CONFIG_HOME/nvim"
abbr -- cxi nvim "$XDG_CONFIG_HOME/x11/xinitrc"
abbr -- cxp nvim "$XDG_CONFIG_HOME/x11/xprofile"
abbr -- cxs nvim "$XDG_CONFIG_HOME/x11/xsession"
abbr -- cxr nvim "$XDG_CONFIG_HOME/x11/xresources"

# system
abbr -- jf journalctl -f
abbr -- jb journalctl -b --no-pager
abbr -- jxe journalctl -xe
abbr -- dm dmesg
abbr -- s sudo systemctl
abbr -- sp sudo pacman
abbr -- sx startx
abbr -- nvsx nvidia-startx

# other
#abbr -- l ls -lah
abbr -- n nvim
abbr -- pkp pkill picom
abbr -- ... cd ../..
abbr -- .... cd ../../..
abbr -- ..... cd ../../../..
abbr -- ...... cd ../../../../..

# for f in ./functions/*.fish
#     source $f
# end

function fish_greeting
end

function sudo -d "Replacement for Bash 'sudo !!' command to run last command using sudo."
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

function c -w code-insiders
    command code-insiders $argv
end

function cr
    if set -q argv[1]
        command code-insiders -r $argv
    else
        command code-insiders -r . $argv
    end
end

function :q
    exit 0
end

function sdks
    command yarn dlx @yarnpkg/sdks $argv
end


complete -c setup-yarn-berry -s s -l stage -d 'add stage plugin'
complete -c setup-yarn-berry -s t -l typescript -d 'add typescript plugin'
complete -c setup-yarn-berry -s i -l interactive-tools -d 'add interactive-tools plugin'
complete -c setup-yarn-berry -s w -l workspace-tools -d 'add workspace-tools plugin'
complete -c setup-yarn-berry -s n -l node-modules -d 'use node-modules and global cache'

function gpus
    command lspci -k | grep -EA3 "(VGA|3D)"
end

function l -w exa
    command exa --long --all --group --git $argv
end

function rm -w rm
    command rm -v $argv
end

function mv -w mv
    command mv -vi $argv
end

function mvn -w mvn
    command mvn -gs "$XDG_CONFIG_HOME/maven/settings.xml" $argv
end

function startx -w startx
    pushd $HOME
    command startx "$XDG_CONFIG_HOME/x11/xinitrc" $argv -- "$XDG_CONFIG_HOME/x11/xserverrc"
    popd
end

function conky -w conky
    command conky --config="$XDG_CONFIG_HOME"/conky/conkyrc.lua
end

function nvidia-settings -w nvidia-settings
    command nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings" $argv
end

function mkcd
    mkdir -p -- "$argv[1]" && cd "$argv[1]"
end

function brightness -w xrandr
    xrandr --output (xrandr | grep " connected" | cut -f1 -d " ") --brightness $argv
end

starship init fish | source
