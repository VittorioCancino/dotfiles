{ ... }:

{
  systemd.user.services.kanshi = {
    Unit.StartLimitIntervalSec = 60;
    Unit.StartLimitBurst = 10;
    Service.RestartSec = 5;
  };

  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile = {
          name = "triple";
          exec = [ "set-wallpaper" ];
          outputs = [
            { criteria = "eDP-1"; mode = "2880x1800@120";  position = "0,0";    scale = 2.0; }
            { criteria = "DP-9";  mode = "1920x1080@120";  position = "1440,0"; scale = 1.0; }
            { criteria = "DP-11"; mode = "1920x1080@240"; position = "3360,0"; scale = 1.0; }
          ];
        };
      }
      {
        profile = {
          name = "dual-samsung";
          exec = [ "set-wallpaper" ];
          outputs = [
            { criteria = "Samsung Electric Company S24F350 H4ZM500517"; mode = "1920x1080@60"; position = "0,0";    scale = 1.0; }
            { criteria = "eDP-1";                              mode = "2880x1800@120"; position = "1920,0"; scale = 2.0; }
          ];
        };
      }
      {
        profile = {
          name = "laptop-only";
          exec = [ "set-wallpaper" ];
          outputs = [
            { criteria = "eDP-1"; mode = "2880x1800@120"; position = "0,0"; scale = 2.0; }
          ];
        };
      }
    ];
  };
}
