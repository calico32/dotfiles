export nvm_default_version="latest"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

set config "$XDG_CONFIG_HOME"
set cache "$XDG_CACHE_HOME"
set data "$XDG_DATA_HOME"
set runtime "$XDG_RUNTIME_DIR"

export EDITOR="nvim"
export QT_QPA_PLATFORMTHEME="qt5ct"
# export vblank_mode=0
export __GL_SYNC_TO_VBLANK=1

export DOTBARE_DIR="$config/dotfiles"
export LESSKEY="$config/less/lesskey"
export LESSHISTFILE="$cache/less/history"
export GNUPGHOME="$data/gnupg"
export GTK2_RC_FILES="$config/gtk-2.0/gtkrc"
export TERMINFO="$data/terminfo"
export TERMINFO_DIRS="$data/terminfo:/usr/share/terminfo"
export WGETRC="$config/wgetrc"
export WINEPREFIX="$data/wineprefixes/default"
export ZDOTDIR="$config/zsh"

export XINITRC="$config/x11/xinitrc"
export XSERVERRC="$config/x11/xserverrc"
export XAUTHORITY="$runtime/xauthority"
export XCOMPOSEFILE="$config/x11/xcompose"
export XCOMPOSECACHE="$cache/x11/xcompose"

export GOPATH="$data/go"
export GRADLE_USER_HOME="$data/gradle"
export CARGO_HOME="$data/cargo"
export RUSTUP_HOME="$data/rustup"
export NODE_REPL_HISTORY="$data/node_repl_history"
export TS_NODE_REPL_HISTORY="$data/ts_node_repl_history"
export NPM_CONFIG_USERCONFIG="$config/npm/npmrc"

export ANDROID_SDK_HOME="$config/android"
export ANDROID_AVD_HOME="$data/android"
export ANDROID_EMULATOR_HOME="$data/android"
export ADB_VENDOR_KEY="$config/android"

export PSQLRC="$config/pg/psqlrc"
export PSQL_HISTORY="$cache/pg/psql_history"
export PGPASSFILE="$config/pg/pgpass"
export PGSERVICEFILE="$config/pg/pg_service.conf"
