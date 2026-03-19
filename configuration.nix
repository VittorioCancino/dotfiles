# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/sddm.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # Boot splash
  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };
  boot.kernelParams = [ "quiet" "splash" ];
  boot.initrd.systemd.enable = true;

  # Nix store hygiene
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;

  networking.hostName = "nixos";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [{
    source = pkgs.writeShellScript "waybar-network-dispatch" ''
      pkill -u vitto -RTMIN+8 waybar || true
    '';
    type = "basic";
  }];

  virtualisation.docker = {
    enable = true;
    # optional but useful:
    enableOnBoot = true;
    autoPrune.enable = true;
  };



  time.timeZone = "America/Santiago";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "es_CL.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "es_CL.UTF-8";
    LC_IDENTIFICATION = "es_CL.UTF-8";
    LC_MEASUREMENT    = "es_CL.UTF-8";
    LC_MONETARY       = "es_CL.UTF-8";
    LC_NAME           = "es_CL.UTF-8";
    LC_NUMERIC        = "es_CL.UTF-8";
    LC_PAPER          = "es_CL.UTF-8";
    LC_TELEPHONE      = "es_CL.UTF-8";
    LC_TIME           = "es_CL.UTF-8";
  };

  # Configure keymap in X11 / XWayland
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.vitto = {
    isNormalUser = true;
    description = "Vittorio Cancino Gonzalez";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Keyring — auto-unlocked by SDDM on login via PAM
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users."vitto" = import ./home.nix;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    jq
    libnotify
    brightnessctl
    gnome-keyring
    libsecret
    gcr_4
    inputs.sddm-theme.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  system.stateVersion = "25.11";
}
