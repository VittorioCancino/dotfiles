{ ... }:
{
  # Ensure D-Bus knows where the keyring socket is
  # PAM + SDDM handles the actual daemon launch
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
}
