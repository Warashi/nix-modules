{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.warashi.cage;
  toYAML = pkgs.formats.yaml { };
in
{
  options.warashi.cage = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable cage config.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      description = "The cage package to use.";
    };
    wrappedPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages to be wrapped with cage.";
    };
    config = lib.mkOption {
      type = toYAML.type;
      default = { };
      description = "Configuration options for cage.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        wrap =
          target:
          pkgs.writeShellApplication {
            name = target.pname;
            runtimeInputs = [
              cfg.package
            ];
            text = ''
              exec "${lib.getExe cfg.package}" -- "${lib.getExe target}" "$@"
            '';
          };
        wrapped = wrap cfg.package;
      in
      [ cfg.package ] ++ wrapped;

    xdg.configFile."cage/presets.yaml".text = toYAML.generate "cage-presets-yaml" cfg.config;
  };
}
