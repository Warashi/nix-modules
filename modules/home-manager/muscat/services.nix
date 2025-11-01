{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.warashi.services.muscat;
in
{
  options.warashi.services.muscat = {
    enable = lib.mkEnableOption "Configure muscat server";
    package = lib.mkOption {
      description = "package for muscat";
      type = lib.types.package;
    };
    xdg-autostart.enable = lib.mkOption {
      description = "enable systemd service";
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux;
    };
    launchd.enable = lib.mkOption {
      description = "enable launchd agent";
      type = lib.types.bool;
      default = pkgs.stdenv.isDarwin;
    };
    additionalPackages = lib.mkOption {
      description = "additional packages to be accessed by muscat server";
      type = lib.types.listOf lib.types.package;
      default = [
      ];
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.mkIf cfg.xdg-autostart.enable {
      muscat-server = {
        text = ''
          [Desktop Entry]
          Name=Muscat Server
          Type=Application
          Exec=${cfg.package}/bin/muscat server
          StartupWMClass=Muscat
          Comment=Start muscat server
          Terminal=false
        '';
        target = "autostart/muscat-server.desktop";
      };
    };

    launchd.agents = lib.mkIf cfg.launchd.enable {
      muscat = {
        enable = true;
        config = {
          Label = "dev.warashi.muscat";
          ProgramArguments = [
            "${cfg.package}/bin/muscat"
            "server"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          EnvironmentVariables = {
            PATH = "${lib.makeBinPath cfg.additionalPackages}:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
        };
      };
    };
  };
}
