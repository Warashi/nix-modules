{
  description = "My Nix modules";

  inputs = {
    # keep-sorted start block=yes
    devshell = {
      url = "github:numtide/devshell";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs = {
        nixpkgs-lib.follows = "nixpkgs-lib";
      };
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
      };
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-lib = {
      url = "github:nix-community/nixpkgs.lib";
    };
    systems = {
      url = "github:nix-systems/default";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    # keep-sorted end
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        # keep-sorted start
        inputs.devshell.flakeModule
        inputs.git-hooks.flakeModule
        inputs.home-manager.flakeModules.home-manager
        inputs.treefmt-nix.flakeModule
        # keep-sorted end
      ];

      flake = {
      };

      perSystem =
        { config, pkgs, ... }:
        {
          pre-commit = {
            check.enable = true;
            settings = {
              src = ./.;
              hooks = {
                actionlint.enable = false;
                treefmt.enable = true;
              };
            };
          };
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              # keep-sorted start
              keep-sorted.enable = true;
              nixfmt.enable = true;
              shfmt.enable = true;
              # keep-sorted end
            };
            settings = {
              formatter = {
                tombi = {
                  command = pkgs.lib.getExe pkgs.tombi;
                  options = [ "format" ];
                  includes = [ "*.toml" ];
                };
                nixfmt = {
                  excludes = [
                    "**/node2nix/*.nix" # node2nix generated files
                    "**/_sources/generated.nix" # nvfetcher generatee sources
                  ];
                };
              };
            };
          };
          devshells.default = {
            devshell = {
              startup = {
                pre-commit = {
                  text = config.pre-commit.installationScript;
                };
              };
            };
          };
        };
    };
}
