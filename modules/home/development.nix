{ pkgs, inputs, ... }:
let
  latexPackages = with pkgs.texlive; pkgs.texlive.combine {
    inherit scheme-full latexmk biber chktex;
  };

  opencodePkgs = import inputs.opencode-master {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  opencode = pkgs.symlinkJoin {
    name = "opencode-wrapped";
    paths = [ opencodePkgs.opencode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ opencodePkgs.stdenv.cc.cc.lib ]}
    '';
  };
in
{
  home.packages = with pkgs; [
    opencode
    nodejs
    pnpm
    docker-compose
    bun
    gcc
    glibc.dev
    clang-tools
    python3
    R
    ripgrep
    unzip

    latexPackages
    texlab
    gnumake
    zathura
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [ "latex" ];
    extraPackages = [
      latexPackages
      pkgs.texlab
      pkgs.gnumake
      pkgs.gcc
      pkgs.glibc.dev
      pkgs.clang-tools
    ];
    userSettings = {
      lsp.texlab = {
        binary = {
          path = "${pkgs.texlab}/bin/texlab";
          ignore_system_version = true;
        };
        settings.texlab.build = {
          executable = "${latexPackages}/bin/latexmk";
          args = [
            "-pdf"
            "-interaction=nonstopmode"
            "-synctex=1"
            "%f"
          ];
          onSave = true;
          forwardSearchAfter = false;
        };
      };
      languages.LaTeX = {
        enable_language_server = true;
        format_on_save = "off";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
