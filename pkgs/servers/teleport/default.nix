{ callPackages, lib, buildGo122Module, ... }@args:
let
  f = args: rec {
    teleport_13 = import ./13 (args // {
      buildGoModule = buildGo122Module; # https://github.com/parquet-go/parquet-go/pull/142
    });
    teleport_14 = import ./14 args;
    teleport_15 = import ./15 args;
    teleport_16 = import ./16 args;
    teleport = teleport_16;
  };
  # Ensure the following callPackages invocation includes everything 'generic' needs.
  f' = lib.setFunctionArgs f (builtins.functionArgs (import ./generic.nix));
in
callPackages f' (builtins.removeAttrs args [ "callPackages" "buildGo122Module" ])
