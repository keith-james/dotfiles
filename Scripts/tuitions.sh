#!/usr/bin/env bash
set -euo pipefail

killall zoom &

CLASSES=("Math Tuition" "Chemistry Tuition" "Physics Tuition")

choice=$(printf '%s\n' "${CLASSES[@]}" | sort | dmenu -i -p 'Choose class:' "$@")

if [ "$choice" = "${CLASSES[0]}" ]; then
    firefox https://zoom.us/j/8426360502 &
    echo test
    echo -n kTT9nH | xclip -sel clip

elif [ "$choice" = "${CLASSES[1]}" ]; then
    firefox https://us04web.zoom.us/j/77678318563?pwd=bWNzUFU4V2JSU3IvTUdjUXdreGtaUT09 &

elif [ "$choice" = "${CLASSES[2]}" ]; then
    firefox https://us04web.zoom.us/j/5078550966?pwd=RXZ4S1lVeFU3cVl4M011cHVyVUJZdz09 9

else
    echo "Wrong Choice :("
fi
