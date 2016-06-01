{ config, pkgs, ... }:

with pkgs;

{

  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  config = {

  boot.isContainer = true;
  networking.useHostResolvConf = false;
  networking.nameservers = [ "8.8.8.8" ];

  ## package flags
  environment.systemPackages = [ pkgs.vim ];
  environment.shellInit = ''
      export EDITOR=vim
  '';

  nix.nixPath = [ "nixpkgs=${./.}"
                  "/nix/var/nix/profiles/per-user/root/channels/nixos"
                  "nixos-config=/etc/nixos/configuration.nix"
                  "/nix/var/nix/profiles/per-user/root/channels"
                ];

  # Security settings
  security.sudo.wheelNeedsPassword = false;

  # User management
  users.mutableUsers = false;
  nixup.enable = true;

  users.extraUsers.test = { 
    description = "Test User";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/test";
    password = "nixup";
  };

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;

  };

}


