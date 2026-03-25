{ ... }:

{
  # Allow thinkpad_acpi to control the fan
  boot.extraModprobeConfig = "options thinkpad_acpi fan_control=1";

  services.thinkfan = {
    enable = true;

    # Use the thinkpad hwmon sensor (CPU temp, index 0 = temp1_input)
    # and k10temp as a secondary source
    sensors = [
      {
        type = "hwmon";
        query = "thinkpad";
        indices = [ 0 ]; # temp1_input → CPU
      }
      {
        type = "hwmon";
        query = "k10temp";
        indices = [ 0 ]; # Tctl
      }
    ];

    # [fan_level  low_°C  high_°C]
    # Fan kicks in at 42°C instead of waiting until it gets hot
    levels = [
      [ 0   0  42 ]
      [ 1  40  48 ]
      [ 2  46  54 ]
      [ 3  52  60 ]
      [ 4  58  65 ]
      [ 5  63  70 ]
      [ 7  68  90 ]
      [ "level disengaged"  85  100 ]
    ];
  };
}
