{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.imperativeNix;

  imperativePackages =
    let
      toPath = builtins.toPath;
      getEnv = x: if builtins ? getEnv then builtins.getEnv x else "";
      pathExists = name:
        builtins ? pathExists && builtins.pathExists (toPath name);
      packagesString = if cfg.configFile == null
                       then if pathExists "${getEnv "XDG_CONFIG_HOME"}/nixup/packages.nix"
                            then readFile (toPath "${getEnv "XDG_CONFIG_HOME"}/nixup/packages.nix")
                            else ""
                       else if pathExists (toPath cfg.configFile)
                            then readFile (toPath cfg.configFile)
                            else "";
    in
      map (x : getAttr x pkgs) (remove "" (map (x: replaceChars ["\n"] [""] x) (splitString "\n" packagesString)));

  imperativeTools = pkgs.stdenv.mkDerivation {
    name = "nix-package";
    buildCommand = ''
      mkdir -p $out/bin
      shell=${pkgs.stdenv.shell}
      coreutils=${pkgs.coreutils}
      gnused=${pkgs.gnused}
      nixup=${config.nixup.build.nixup}
      nix=${config.nix.package}
      substituteAll ${./nix-packages.sh} $out/bin/nix-package
      chmod +x $out/bin/nix-package
    '';
  };



in

{
  options = {

    imperativeNix = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Include concent of "imperativeNix.configFile" into "user.packages".
        '';
      };
      configFile = mkOption {
        default = null;
        type = types.nullOr types.path;
        description = ''
          Path of file to include into "user.packages".
          "null" uses "$XDG_CONFIG_HOME/nixup/packages.nix".
        '';
      };
    };
  };

  config = {

    user.packages = mkIf cfg.enable ([ imperativeTools ] ++ imperativePackages);

  };
}
