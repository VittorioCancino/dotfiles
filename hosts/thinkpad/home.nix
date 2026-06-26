{ ... }:

{
  imports = [
    ./kanshi.nix
  ];

  local.machine = {
    tabletOutput = "DP-10";
    bindF4MicMute = true;
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "blueman-applet"
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."ssh.dev.azure.com" = {
      IdentityFile = "~/.ssh/id_rsa_azure";
      User = "git";
    };
    settings."github.com" = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = true;
      AddKeysToAgent = "yes";
    };
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };

  home.file.".ssh/config".force = true;
}
