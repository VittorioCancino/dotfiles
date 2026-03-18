{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swww
    matugen
    imagemagick

    (writeShellScriptBin "set-wallpaper" ''
      WALLPAPER="$1"
      TRANSITION="''${2:-grow}"

      # If no argument given, restore last used wallpaper
      if [ -z "$WALLPAPER" ]; then
        WALLPAPER=$(cat ~/.cache/current-wallpaper 2>/dev/null)
      fi

      if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
        echo "Usage: set-wallpaper <path> [transition]"
        echo "Transitions: wipe fade slide wave grow outer random"
        exit 1
      fi

      # Set wallpaper
      swww img "$WALLPAPER" \
        --transition-type "$TRANSITION" \
        --transition-duration 1

      # Remember for next login
      echo "$WALLPAPER" > ~/.cache/current-wallpaper
      ln -sf "$WALLPAPER" ~/.cache/current-wallpaper.img

      # Generate resized copy for rofi card (fast load, no decode lag)
      magick "$WALLPAPER" -resize 600x ~/.cache/rofi-wallpaper.jpg

      # Generate color palette (pick most prominent color automatically)
      matugen image "$WALLPAPER" --source-color-index 0

      # Reload waybar CSS
      pkill -SIGUSR2 waybar

      # Reload mako with new colors
      makoctl reload 2>/dev/null || true

      # Reload Hyprland config to pick up new border colors
      hyprctl reload 2>/dev/null || true

      # Reload GTK theme so running apps pick up new colors
      gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
    '')
  ];

  # Ensure wallpapers directory exists
  home.file."Pictures/wallpapers/.keep".text = "";

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "swww-daemon"
    ];
  };
}
