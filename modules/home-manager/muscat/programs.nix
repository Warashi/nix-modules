{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.warashi.programs.muscat;
in
{
  options.warashi.programs.muscat = {
    enable = lib.mkEnableOption "Enable muscat";
    package = lib.mkOption {
      description = "package for muscat";
      type = lib.types.package;
    };
    extraSymlinks = lib.mkOption {
      description = "extra symlinks for muscat binary";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ]
    ++ lib.optional (cfg.extraSymlinks != [ ]) (
      pkgs.runCommand "muscat-symlinks" { } ''
        mkdir -p $out/bin && cd $out/bin
        ${lib.concatLines (
          lib.forEach cfg.extraSymlinks (x: ''
            ln -s ${cfg.package}/bin/muscat ${x};
          '')
        )}
      ''
    );
  };
}
