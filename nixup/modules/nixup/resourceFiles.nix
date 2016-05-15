{ config, lib, pkgs, ... }:

with lib;

let
  makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

  nixup-resources = makeProg {
    name = "nixup-resources";
    src = ./nixup-resources.sh;
    coreutils = pkgs.coreutils;
  };
in

{
  options = {
    user.resourceFiles = mkOption rec {
      default = {};
      type = types.loaOf (types.submodule options);
      example = literalExample ''
        [ { target = ".ssh/config";
            text = "
              Host home.my-domain.name
              User seti
            ";
          }
          { target = ".gitconfig";
            source = ./gitconfig;
          }
        ]
      '';
      description = ''
        Set of files that have to be linked in the home directory.
      '';

      options = { name, config, ... }: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this <filename>~/.</filename> file should be generated.  This
              option allows specific <filename>~/.</filename> files to be disabled.
            '';
          };

          target = mkOption {
            type = types.relativePath;
            description = ''
              Name of symlink (relative to <filename>~/.</filename>).
              Defaults to the attribute name.
            '';
          };

          text = mkOption {
            default = null;
            type = types.nullOr types.lines;
            description = "Text of the file.";
          };

          source = mkOption {
            type = types.path;
            description = "Path of the source file.";
          };

          setupScript = mkOption {
            type = types.lines;
            internal = true;
            description = ''
              Shell script code to produce the resource file.
              NOTE: The script will be executed within mkDerivation.
            '';
          };

        };

        config = {
          target = mkDefault name;
          source = mkIf (config.text != null)
            (mkDefault (pkgs.writeText "homeDir-${name}" config.text));

          setupScript = mkDefault ''
            target="$out/${config.target}"
            mkdir -p $(dirname $target)
            ln -s "${config.source}" $target
          '';
        };
      };

    };
  };

  config = {
    nixup.build.nixup-resources = nixup-resources;

    nixup.buildCommands = ''
      mkdir -p $out
      ln -s ${pkgs.runCommand "nixup-resource-collection" { } ("mkdir $out\n" + (concatMapStringsSep "\n" (rc: rc.setupScript) (attrValues config.user.resourceFiles)))} $out/resources

      echo "${concatMapStringsSep "\n" (rc: rc.target) (attrValues config.user.resourceFiles)}" > $out/resourceTargets

      ##
      ## create resource linking/unlinking/switching commands
      ## NOTE: The commands link directly to the derivation of the profile, and not to $NIXUP_RUNTIME_DIR/active-profile!
      ##
      mkdir -p $out/bin
      echo "#! ${pkgs.stdenv.shell}" > $out/bin/nixup-resources-link
      echo "${nixup-resources}/bin/nixup-resources --link $out" >> $out/bin/nixup-resources-link
      chmod +x $out/bin/nixup-resources-link
      echo "#! ${pkgs.stdenv.shell}" > $out/bin/nixup-resources-unlink
      echo "${nixup-resources}/bin/nixup-resources --unlink $out" >> $out/bin/nixup-resources-unlink
      chmod +x $out/bin/nixup-resources-unlink
      echo "#! ${pkgs.stdenv.shell}" > $out/bin/nixup-resources-switchfrom
      echo "${nixup-resources}/bin/nixup-resources --switch \$1 $out" >> $out/bin/nixup-resources-switchfrom
      chmod +x $out/bin/nixup-resources-switchfrom
      echo "#! ${pkgs.stdenv.shell}" > $out/bin/nixup-resources-switchto
      echo "${nixup-resources}/bin/nixup-resources --switch $out \$1" >> $out/bin/nixup-resources-switchto
      chmod +x $out/bin/nixup-resources-switchto
    '';

    nixup.activationScripts.resourceFiles = ''
      echo "Setting up resource files ..."
      if [ -L "$NIXUP_USER_GCROOTS_DIR/old-active-profile" ]; then
          ${nixup-resources}/bin/nixup-resources --switch $NIXUP_USER_GCROOTS_DIR/old-active-profile $NIXUP_RUNTIME_DIR/active-profile
      fi
      ${nixup-resources}/bin/nixup-resources --link $NIXUP_RUNTIME_DIR/active-profile
    '';
  };
}
