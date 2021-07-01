#!/usr/bin/env bash 

picom --experimental-backends --backend glx --vsync &
nitrogen --restore &
xfce4-power-manager &
xmodmap ~/.Xmodmap &
