#!/usr/bin/bash
#
# Total Chaos launcher script

# Migrate existing (legacy) config if present
if [ -f ~/.var/app/${FLATPAK_ID}/.config/gzdoom/gzdoom.ini ]; then
    if [ ! -f /var/config/uzdoom/uzdoom.ini ]; then
        echo "Copying existing gzdoom.ini to uzdoom.ini"
        mkdir -p /var/config/uzdoom
        cp ~/.var/app/${FLATPAK_ID}/.config/gzdoom/gzdoom.ini /var/config/uzdoom/uzdoom.ini
    fi
fi

# Copy default config if not present
if [ ! -f /var/config/uzdoom/uzdoom.ini ]; then
    echo "Copying default gzdoom_portable.ini to uzdoom.ini"
    mkdir -p /var/config/uzdoom
    cp /app/share/games/uzdoom/gzdoom_portable.ini /var/config/uzdoom/uzdoom.ini
fi

WM_CLASS="${FLATPAK_ID:-uzdoom}"

# Export environment variables for SDL2 (UZDoom)
export SDL_VIDEO_X11_WMCLASS="$WM_CLASS"
export SDL_VIDEO_WAYLAND_WMCLASS="$WM_CLASS"

# Run game engine
exec uzdoom -iwad freedoom2.wad \
    -file totalchaos.pk3 \
    +set fluid_patchset /app/share/games/uzdoom/soundfonts/uzdoom.sf2 "$@"
