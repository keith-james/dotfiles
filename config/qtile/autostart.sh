#!/usr/bin/env bash 

xfce4-power-manager &
zsh -c '$HOME/.config/wpg/wp_init.sh' &
picom --experimental-backends --backend glx --vsync &
xmodmap ~/.Xmodmap &
