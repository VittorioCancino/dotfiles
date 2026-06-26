{ pkgs, ... }:

let
  importSessionEnv = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DBUS_SESSION_BUS_ADDRESS SSH_AUTH_SOCK";
in
{
  # GNOME Keyring is kept for app secrets; SSH keys are handled by OpenSSH's agent.
  wayland.windowManager.hyprland.settings."exec-once" = [
    importSessionEnv
    "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets,pkcs11"
  ];
}
