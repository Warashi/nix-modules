localFlake: flakeArgs:
builtins.foldl' (acc: elem: acc // elem) { } (
  builtins.map (module: import ./. + "/${module}" localFlake) (
    builtins.filter (x: x != "default.nix") (builtins.attrNames (builtins.readDir ./.))
  )
)
