{ lib, pkgs, ... }:

let
  chromiumBin = "${pkgs.chromium}/bin/chromium";
in
{
  home.packages = with pkgs; [
    firefox
    chromium
    vscode
    thunar
    pgadmin4-desktopmode
    qalculate-gtk
    discord
    spotify
    anydesk
    pavucontrol

    (writeShellScriptBin "pgadmin4-launch" ''
      url="http://127.0.0.1:5050"
      log_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/pgadmin4"
      mkdir -p "$log_dir"

      if ! ${curl}/bin/curl -fsS "$url" >/dev/null 2>&1; then
        nohup ${pgadmin4-desktopmode}/bin/pgadmin4 > "$log_dir/pgadmin4.log" 2>&1 &

        for _ in $(seq 1 30); do
          ${curl}/bin/curl -fsS "$url" >/dev/null 2>&1 && break
          sleep 1
        done
      fi

      exec ${xdg-utils}/bin/xdg-open "$url"
    '')
  ];

  home.sessionVariables = {
    CHROME_BIN = chromiumBin;
    CHROME_EXECUTABLE = chromiumBin;
    CHROMIUM_BIN = chromiumBin;
    PUPPETEER_EXECUTABLE_PATH = chromiumBin;
  };

  home.activation.configureVscodeChromium = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings_file="$HOME/.config/Code/User/settings.json"
    tmp_file="$(${pkgs.coreutils}/bin/mktemp)"

    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/Code/User"

    if [ -s "$settings_file" ]; then
      ${pkgs.jq}/bin/jq '. + {
        "markdown-pdf.executablePath": "${chromiumBin}",
        "markdown-pdf.chromium.autoDownload": false
      }' "$settings_file" > "$tmp_file"
    else
      ${pkgs.jq}/bin/jq -n '{
        "markdown-pdf.executablePath": "${chromiumBin}",
        "markdown-pdf.chromium.autoDownload": false
      }' > "$tmp_file"
    fi

    ${pkgs.coreutils}/bin/install -m 0644 "$tmp_file" "$settings_file"
    ${pkgs.coreutils}/bin/rm -f "$tmp_file"
  '';

  xfconf.settings.thunar = {
    "default-view" = "ThunarDetailsView";
    "misc-directory-specific-settings" = false;
  };

  home.file.".local/share/applications/pgadmin4.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=pgAdmin 4
    Comment=PostgreSQL administration and development platform
    Exec=pgadmin4-launch
    Icon=${../../assets/postgresql-elephant.png}
    Terminal=false
    Categories=Development;Database;
  '';
}
