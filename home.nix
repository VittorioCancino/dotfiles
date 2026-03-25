{ config, pkgs, inputs, ... }:

{
  home.username = "vitto";
  home.homeDirectory = "/home/vitto";
  home.stateVersion = "25.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    vscode
    firefox
    thunar
    nodejs
    discord
    docker-compose
    bun
    spotify

    # Toggle mic mute and sync the ThinkPad mic LED
    (writeShellScriptBin "toggle-mic" ''
      wpctl set-source-mute @DEFAULT_SOURCE@ toggle
      led=$(brightnessctl --device='platform::micmute' get)
      brightnessctl --device='platform::micmute' set $((1 - led))
    '')

    # Toggle speaker mute and sync the ThinkPad mute LED
    (writeShellScriptBin "toggle-mute" ''
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      led=$(brightnessctl --device='platform::mute' get)
      brightnessctl --device='platform::mute' set $((1 - led))
    '')
  ];

  programs.zed-editor.enable = true;
  services.ssh-agent.enable = true;

  home.file.".face".source = ./assets/avatar.png;

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name    = "Bibata-Modern-Classic";
    size    = 18;
    gtk.enable = true;
  };

  programs.home-manager.enable = true;

  imports = [
    ./modules/home/hyprland.nix
    ./modules/home/kanshi.nix
    ./modules/home/swww.nix
    ./modules/home/wezterm.nix
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
