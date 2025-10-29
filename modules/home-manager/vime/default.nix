{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.warashi.vime;

  sources = pkgs.callPackage ./_sources/generated.nix { };
  vimrc = pkgs.replaceVars ./config/init.vim {
    deno = "${pkgs.deno}/bin/deno";
    skk_jisyo_l = "${sources.skk-dict.src}/json/SKK-JISYO.L.json";
    ddc_config_ts = pkgs.writeTextFile {
      name = "ddc-config.ts";
      text = builtins.readFile ./config/ddc.ts;
    };
    merged_plugins = pkgs.symlinkJoin {
      name = "nvim-plugins";
      paths =
        (lib.filter (x: x != null) (
          builtins.map (s: if s ? src then s.src else null) (lib.attrsets.attrValues sources)
        ))
        ++ (
          let
            ts = pkgs.vimPlugins.nvim-treesitter;
          in
          [ ts ] ++ ts.withAllGrammars.dependencies
        );
      postBuild = ''
        rm -f $out/deno.json $out/deno.jsonc
      '';
    };
  };

  tmux-default-shell = pkgs.writeShellApplication {
    name = "tmux-default-shell";
    runtimeInputs = [
      pkgs.tmux
      vim-as-ime
    ];
    text = ''
      while true; do
        vime
        tmux detach-client
      done
    '';
  };

  tmux-config = pkgs.replaceVars ./config/tmux.conf {
    tmux_default_shell = lib.getExe tmux-default-shell;
  };

  vim-as-ime = pkgs.writeShellApplication {
    name = "vime";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.neovim
    ];
    text = ''
      clip="$(mktemp /tmp/clip.XXXXXX.md)"
      trap 'rm -f $clip' EXIT
      nvim -u ${vimrc} "$clip"
      if [[ -s "$clip" ]]; then
        pbcopy < "$clip"
      fi
    '';
  };

  vime-tmux-session = pkgs.writeShellApplication {
    name = "vime-tmux-session";
    runtimeInputs = [
      pkgs.tmux
    ];
    text = ''
      exec tmux -L vime-session -f ${tmux-config} new-session -A
    '';
  };
in
{
  options.warashi.vime = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Neovim as IME.";
    };
    enableRaycast = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isDarwin;
      description = "Enable Raycast integration for Neovim as IME (macOS only).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      vim-as-ime
      vime-tmux-session
    ];
    xdg = {
      configFile = {
        "raycast/vim-as-ime.sh" = {
          enable = cfg.enableRaycast;
          executable = true;
          source = pkgs.writeShellScript "vim-as-ime" ''
            # Required parameters:
            # @raycast.schemaVersion 1
            # @raycast.title Neovim as IME
            # @raycast.mode silent

            # Optional parameters:
            # @raycast.icon 🤖

            open -a Alacritty.app --wait-apps --args --command "${lib.getExe vime-tmux-session}"
          '';
        };
      };
    };
  };
}
