#!/usr/bin/bash

if [ -f ~/.config/gzdoom/gzdoom.ini ]; then
    if [ ! -f /var/config/uzdoom/uzdoom.ini ]; then
        echo "Copying existing gzdoom.ini to uzdoom.ini"
        mkdir -p /var/config/uzdoom
        cp ~/.config/gzdoom/gzdoom.ini /var/config/uzdoom/uzdoom.ini
    fi
fi

if [ ! -f /var/config/uzdoom/uzdoom.ini ]; then
    echo "Copying default gzdoom_portable.ini to uzdoom.ini"
    mkdir -p /var/config/uzdoom
    cp /app/share/games/uzdoom/gzdoom_portable.ini /var/config/uzdoom/uzdoom.ini
fi

# Run game engine
exec uzdoom -file totalchaos.pk3 +fluid_patchset /app/share/games/uzdoom/soundfonts/gzdoom.sf2 "$@"
