{ ... }:

{
  programs.wlogout = {
    enable = true;

    layout = [
      { label = "lock";     action = "loginctl lock-session"; text = "Lock";     keybind = "l"; }
      { label = "suspend";  action = "systemctl suspend";     text = "Suspend";  keybind = "s"; }
      { label = "reboot";   action = "systemctl reboot";      text = "Reboot";   keybind = "r"; }
      { label = "shutdown"; action = "systemctl poweroff";    text = "Shutdown"; keybind = "p"; }
    ];

    style = ''
      @import url("/home/vitto/.cache/matugen/waybar.css");

      * {
        background-image: none;
        box-shadow:       none;
      }

      window {
        background-color: rgba(0, 0, 0, 0.5);
        font-family:      "JetBrainsMono Nerd Font";
      }

      button {
        background-color: @background;
        color:            @foreground;
        border:           2px solid transparent;
        border-radius:    16px;
        font-size:        13px;
        margin:           8px;
        padding:          0;
        transition:       background-color 200ms,
                          color            200ms,
                          border-color     200ms;
      }

      button:focus,
      button:hover {
        background-color: @primary;
        color:            @on_primary;
        border-color:     @primary;
        outline:          none;
      }

      button:active {
        background-color: @primary;
        color:            @on_primary;
      }
    '';
  };

}
