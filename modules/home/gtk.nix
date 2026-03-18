{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name    = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3.extraCss = ''
      @import url("file:///home/vitto/.cache/matugen/gtk-colors.css");

      headerbar {
        background-color: @accent_bg_color;
        color: @accent_fg_color;
      }
    '';

    gtk4.extraCss = ''
      @import url("file:///home/vitto/.cache/matugen/gtk-colors.css");
    '';
  };

  # Signal apps to prefer dark color scheme
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
