{ username, homeDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11"; # Please read the comment before changing.

  imports = [
    ./modules/home/profile.nix
    ./modules/home/apps.nix
    ./modules/home/development.nix
    ./modules/home/terminal.nix
    ./modules/home/scripts.nix
    ./modules/home/opencode-waybar.nix
    ./modules/home/hyprland.nix
    ./modules/home/wallpaper.nix
    ./modules/home/zsh.nix
    ./modules/home/matugen.nix
    ./modules/home/waybar.nix
    ./modules/home/network.nix
    ./modules/home/hyprlock.nix
    ./modules/home/hypridle.nix
    ./modules/home/screenshot.nix
    ./modules/home/rofi.nix
    ./modules/home/eww.nix
    ./modules/home/mako.nix
    ./modules/home/keyring.nix
    ./modules/home/cliphist.nix
    ./modules/home/gtk.nix
    ./modules/home/yazi.nix
  ];
}
