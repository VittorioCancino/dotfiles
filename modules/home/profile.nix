{ pkgs, ... }:

{
  home.file.".face".source = ../../assets/avatar.png;

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 18;
    gtk.enable = true;
  };

  programs.home-manager.enable = true;
}
