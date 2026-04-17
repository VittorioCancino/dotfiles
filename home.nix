{ config, pkgs, inputs, ... }:
let
  latexPackages = with pkgs.texlive; pkgs.texlive.combine {
    inherit scheme-full latexmk biber chktex;
  };
in
{
  home.username = "vitto";
  home.homeDirectory = "/home/vitto";
  home.stateVersion = "25.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    firefox
    vscode
    thunar
    nodejs
    pnpm
    discord
    docker-compose
    bun
    spotify
    gcc
    glibc.dev
    clang-tools
    python3


    # LaTeX
    latexPackages
    texlab
    gnumake
    zathura

    ripgrep

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

  programs.zed-editor = {
    enable = true;
    extensions = [ "latex" ];
    extraPackages = [
      latexPackages
      pkgs.texlab
      pkgs.gnumake
      pkgs.gcc
      pkgs.glibc.dev
      pkgs.clang-tools
    ];
    userSettings = {
      lsp.texlab = {
        binary = {
          path = "${pkgs.texlab}/bin/texlab";
          ignore_system_version = true;
        };
        settings.texlab.build = {
          executable = "${latexPackages}/bin/latexmk";
          args = [
            "-pdf"
            "-interaction=nonstopmode"
            "-synctex=1"
            "%f"
          ];
          onSave = true;
          forwardSearchAfter = false;
        };
      };
      languages.LaTeX = {
        enable_language_server = true;
        format_on_save = "off";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
