#!/usr/bin/env bash

set -euo pipefail

backup_and_link() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" || -L "$target" ]]; then
        local dir
        local base
        local backup

        dir="$(dirname "$target")"
        base="$(basename "$target")"
        backup="${dir}/OLD${base}"

        local n=1
        while [[ -e "$backup" || -L "$backup" ]]; do
            backup="${dir}/OLD${base}.${n}"
            ((n++))
        done

        echo "Backing up $target -> $backup"
        mv "$target" "$backup"
    fi

    echo "Linking $target -> $source"
    ln -s "$source" "$target"
}

cd "$HOME"

backup_and_link "$HOME/radian/shell/zsh/.zshrc"            "$HOME/.zshrc"
backup_and_link "$HOME/radian/shell/zsh/.zshenv"           "$HOME/.zshenv"
backup_and_link "$HOME/radian/shell/zsh/.zprofile"         "$HOME/.zprofile"
backup_and_link "$HOME/radian/shell/shared/.profile"       "$HOME/.profile"

backup_and_link "$HOME/my_configs/.zshrc.local"            "$HOME/.zshrc.local"
backup_and_link "$HOME/my_configs/.profile.local"          "$HOME/.profile.local"
backup_and_link "$HOME/my_configs/aliases.zsh"             "$HOME/aliases.zsh"
backup_and_link "$HOME/my_configs/.gitconfig.local"        "$HOME/.gitconfig.local"
backup_and_link "$HOME/my_configs/.gitexclude.local"       "$HOME/.gitexclude.local"

backup_and_link "$HOME/radian/git/.gitconfig"              "$HOME/.gitconfig"
backup_and_link "$HOME/radian/git/.gitexclude"             "$HOME/.gitexclude"

mkdir -p "$HOME/.emacs.d"

backup_and_link "$HOME/radian/emacs/early-init.el"         "$HOME/.emacs.d/early-init.el"
backup_and_link "$HOME/radian/emacs/init.el"               "$HOME/.emacs.d/init.el"
backup_and_link "$HOME/radian/emacs/radian.el"             "$HOME/.emacs.d/radian.el"

echo "Setup complete."
