{ config, pkgs, inputs, ... }:

let
  username = config.local.user.name;
  oldKernelPkgs = inputs.nixpkgs-bluetooth-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/system/bluetooth.nix
    ./thinkfan.nix
  ];

  networking.hostName = "thinkpad";

  local.user = {
    name = "vitto";
    fullName = "Vittorio Cancino Gonzalez";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # Keep the kernel version where Bluetooth is known to work on this machine.
  boot.kernelPackages = oldKernelPkgs.linuxPackages;

  local.audio.bluetoothA2dpDeviceNames = [
    "bluez_card.60_AB_D2_7A_05_7A"
  ];

  hardware.i2c.enable = true;
  users.users.${username}.extraGroups = [ "i2c" ];
  boot.kernelModules = [ "uinput" ];

  services.udev.packages = [ pkgs.xppen_4 ];
  environment.systemPackages = [ pkgs.xppen_4 ];

  # Disable USB autosuspend for the integrated camera (Chicony 04f2:b840).
  # It fails to resume from suspend (-EINVAL) and gets permanently disconnected.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="04f2", ATTR{idProduct}=="b840", ATTR{power/autosuspend}="-1"
  '';

  home-manager.users.${username}.imports = [ ./home.nix ];

  system.stateVersion = "25.11";
}
