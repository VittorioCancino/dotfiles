{ config, lib, ... }:

{
  options.local.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "vitto";
      description = "Primary local user account name for this host.";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = config.local.user.name;
      description = "Display name for the primary local user account.";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.local.user.name}";
      description = "Home directory for the primary local user account.";
    };
  };
}
