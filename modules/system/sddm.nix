{ pkgs, inputs, ... }:

{
  services.accounts-daemon.enable = true;
  systemd.tmpfiles.rules = [
    "L+ /var/lib/AccountsService/icons/vitto - - - - ${../../assets/avatar.png}"
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "silent";
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
      layer-shell-qt
      pkgs.qt6.qtwayland
    ];
    settings = {
      Wayland.EnableHiDPI = true;
    };
  };
}
