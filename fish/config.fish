
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
set fs "$XDG_DATA_HOME/pictures/flameshot"

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
abbr -- u systemctl --user
abbr -- sp sudo pacman
abbr -- sx startx
abbr -- nvsx nvidia-startx

# other
#abbr -- l ls -lah
abbr -- n nvim
abbr -- yt-dlp yt-dlp --cookies-from-browser brave+gnomekeyring:Default -vU
abbr -- pkp pkill picom
abbr -- ... cd ../..
abbr -- .... cd ../../..
abbr -- ..... cd ../../../..
abbr -- ...... cd ../../../../..
# thefuck --alias | source
function fuck -d "Correct your previous console command"
  set -l fucked_up_command $history[1]
  env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
  if [ "$unfucked_command" != "" ]
    eval $unfucked_command
    builtin history delete --exact --case-sensitive -- $fucked_up_command
    builtin history merge
  end
end

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

function tar-zstd-split
    set input $argv[1]
    set output $argv[2]
    if not set -q argv[1]; or not set -q argv[2]
        echo "usage: tar-zstd-split <input> <output.tar.zst.>"
        return 1
    end
    if not set -q split_size
        set split_size 200MB
    end
    if not set -q ZSTD_CLEVEL
        set ZSTD_CLEVEL 19
    end
    if not set -q ZSTD_NBTHREADS
        set ZSTD_NBTHREADS (nproc)
    end
    ZSTD_CLEVEL=$ZSTD_CLEVEL ZSTD_NBTHREADS=$ZSTD_NBTHREADS command tar -cv --use-compress-program=zstdmt $input | split --bytes=$split_size -a3 - $output
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
    command exa --long --all --git $argv
end

function lg -w exa
    l -g
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
