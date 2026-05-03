{ config, pkgs, inputs, ... }:
let
  latexPackages = with pkgs.texlive; pkgs.texlive.combine {
    inherit scheme-full latexmk biber chktex;
  };

  opencodePkgs = import inputs.opencode-master {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  postgresqlIcon = pkgs.fetchurl {
    url = "https://www.postgresql.org/media/img/about/press/elephant.png";
    sha256 = "1gjp16vkqn6308giw0h2v375ig2gvwp3sh7bq8inpym729fzp4pz";
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
    pgadmin4-desktopmode
    qalculate-gtk
    opencodePkgs.opencode
    nodejs
    pnpm
    discord
    docker-compose
    bun
    (writeShellScriptBin "pgadmin4-launch" ''
      url="http://127.0.0.1:5050"
      log_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/pgadmin4"
      mkdir -p "$log_dir"

      if ! ${curl}/bin/curl -fsS "$url" >/dev/null 2>&1; then
        nohup ${pgadmin4-desktopmode}/bin/pgadmin4 > "$log_dir/pgadmin4.log" 2>&1 &

        for _ in $(seq 1 30); do
          ${curl}/bin/curl -fsS "$url" >/dev/null 2>&1 && break
          sleep 1
        done
      fi

      exec ${xdg-utils}/bin/xdg-open "$url"
    '')
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

  programs.btop = {
    enable = true;

    settings = {
      color_theme = "Default";
      theme_background = false;

      update_ms = 1000;
      graph_symbol = "braille";
      rounded_corners = true;
      vim_keys = true;

      shown_boxes = "cpu mem net proc";
      proc_sorting = "cpu lazy";
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      show_coretemp = true;
      show_cpu_freq = true;
      show_battery = true;
      show_disks = true;
      show_io_stat = true;
    };
  };

  programs.alacritty = {
    enable = true;

    settings = {
      general.import = [ "~/.cache/matugen/alacritty-colors.toml" ];

      window = {
        opacity = 0.85;
        decorations = "None";
        padding = {
          x = 8;
          y = 8;
        };
      };

      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 12.0;
      };

      terminal.shell.program = "zsh";
    };
  };

  home.file.".local/share/applications/pgadmin4.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=pgAdmin 4
    Comment=PostgreSQL administration and development platform
    Exec=pgadmin4-launch
    Icon=${postgresqlIcon}
    Terminal=false
    Categories=Development;Database;
  '';

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
