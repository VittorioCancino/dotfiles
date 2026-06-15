{ config, lib, ... }:

let
  cfg = config.local.audio;
in
{
  options.local.audio.bluetoothA2dpDeviceNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Bluetooth card device names that should be forced to the A2DP sink profile.";
  };

  config = lib.mkIf config.local.features.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        extraConfig."10-bluez" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = false;
            "device.restore-profile" = false;
          };
          "monitor.bluez.properties" = {
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "hsp_hs"
              "hsp_ag"
              "hfp_hf"
              "hfp_ag"
            ];
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
          };
          "monitor.bluez.rules" = map (deviceName: {
            matches = [
              { "device.name" = deviceName; }
            ];
            actions = {
              update-props = {
                "device.profile" = "a2dp-sink";
                "bluez5.auto-connect" = [ "a2dp_sink" ];
                "bluez5.hw-volume" = [ "a2dp_sink" ];
              };
            };
          }) cfg.bluetoothA2dpDeviceNames;
        };
      };
    };
  };
}
