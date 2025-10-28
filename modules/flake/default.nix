localFlake: flakeArgs:
builtins.foldl' (acc: elem: acc // elem) { } (
  builtins.map (module: import (./. + "/${module}") localFlake flakeArgs) (
    builtins.filter (x: x != "default.nix") (builtins.attrNames (builtins.readDir ./.))
  )
)
