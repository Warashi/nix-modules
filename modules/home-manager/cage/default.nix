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
          let
            name = if target ? meta && target.meta ? mainProgram then target.meta.mainProgram else target.pname;
          in
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [
              target
            ];
            # we cannot use "${lib.getExe target}" because cage's auto-preset feature cannot handle full-path executables
            text = ''
              exec "${lib.getExe cfg.package}" -- "${name}" "$@"
            '';
          };
        wrapped = builtins.map wrap cfg.wrappedPackages;
      in
      [ cfg.package ] ++ wrapped;

    xdg.configFile."cage/presets.yaml".source = toYAML.generate "cage-presets-yaml" cfg.config;
  };
}
