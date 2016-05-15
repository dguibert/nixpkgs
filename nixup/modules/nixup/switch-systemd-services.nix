{ config, lib, pkgs, ... }:

with lib;

{

  config = {

    nixup.buildCommands = ''
      mkdir -p $out/bin
      perl="${pkgs.perl}/bin/perl -I${pkgs.perlPackages.FileSlurp}/lib/perl5/site_perl";
      coreutils=${pkgs.coreutils}
      systemd=${config.systemd.package}
      substituteAll ${./switch-systemd-services.pl} $out/bin/switch-systemd-services
      chmod +x $out/bin/switch-systemd-services
    '';

    nixup.activationScripts.resourceFiles = ''
      echo "Setting up systemd user services ..."
      mkdir -p $XDG_RUNTIME_DIR/systemd
      if [ ! -L "$XDG_RUNTIME_DIR/systemd/user" ]; then
          ln -sf $NIXUP_RUNTIME_DIR/active-profile/systemd $XDG_RUNTIME_DIR/systemd/user
      fi
    '';

  };

}
