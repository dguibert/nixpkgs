Setup NixOS container with NixUP installed:
  make create
  make start

Load sample 'profile.nix':
  make profile

Login to new container:
  make ssh   (password: nixup)

Activate NixUP for user 'test':
  nixup switch
    (the profile is located at $XDG_CONFIG_HOME/nixup/profile.nix)

Build and inspect NixUP environment:
  nixup build
  systemctl --user status

Install and remove packages imperatively:
  nix-package install hello
    (the package is inserted into $XDG_CONFIG_HOME/nixup/packages.nix)
  nix-package remove hello

Edit and update NixUP configuration:
  nixup edit
  nixup switch
    or
  nixup login    (which switches to new profile on next login)
