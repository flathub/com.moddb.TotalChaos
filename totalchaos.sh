#!/usr/bin/bash
#
# Total Chaos launcher script

function setup_preferred_backend() {
    
    local uzdoom_config_dir="$XDG_CONFIG_HOME/uzdoom"
    local uzdoom_ini_file="$uzdoom_config_dir/uzdoom.ini"
    local prefer_vulkan=false

    for vendor_file in /sys/class/drm/card*/device/vendor; do
        vendor_hex=$(cat "$vendor_file" 2>/dev/null)
        if [ -n "$vendor_hex" ] && [ "$vendor_hex" != "0x8086" ]; then
            prefer_vulkan=true
            break 
        fi
    done

    if [ "$prefer_vulkan" = true ]; then
        echo "Found dedicated GPU or hybrid system: preferring Vulkan backend"
        sed -i 's/^vid_preferbackend=.*/vid_preferbackend=1/' "$uzdoom_ini_file"
    else
        echo "Intel or anomaly detected: preferring OpenGL backend (fallback to default)"
        sed -i 's/^vid_preferbackend=.*/vid_preferbackend=0/' "$uzdoom_ini_file"
    fi

    # Clean shader cache before starting to avoid conflicts
    if [ -d "$XDG_CACHE_HOME" ]; then
        echo "Cleaning shader cache..."
        rm -rf "$XDG_CACHE_HOME/*"
    fi
}

# Migrate existing (legacy) config if present
if [ -f ~/.var/app/${FLATPAK_ID}/.config/gzdoom/gzdoom.ini ]; then
    if [ ! -f /var/config/uzdoom/uzdoom.ini ]; then
        echo "Copying existing gzdoom.ini to uzdoom.ini"
        mkdir -p /var/config/uzdoom
        cp ~/.var/app/${FLATPAK_ID}/.config/gzdoom/gzdoom.ini /var/config/uzdoom/uzdoom.ini
        setup_preferred_backend
    fi
fi

# Copy default config if not present
if [ ! -f /var/config/uzdoom/uzdoom.ini ]; then
    echo "Copying default gzdoom_portable.ini to uzdoom.ini"
    mkdir -p /var/config/uzdoom
    cp /app/share/games/uzdoom/gzdoom_portable.ini /var/config/uzdoom/uzdoom.ini
    setup_preferred_backend
fi

WM_CLASS="${FLATPAK_ID:-uzdoom}"

# Export environment variables for SDL2 (UZDoom)
export SDL_VIDEO_X11_WMCLASS="$WM_CLASS"
export SDL_VIDEO_WAYLAND_WMCLASS="$WM_CLASS"

# Run game engine
exec uzdoom -iwad freedoom2.wad \
    -file totalchaos.pk3 \
    +set fluid_patchset /app/share/games/uzdoom/soundfonts/uzdoom.sf2 "$@"
