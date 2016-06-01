# This module generates the nixup command

{ config, pkgs, lib, ... }:

let

  cfg = config.installer;

  makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

  nixup = makeProg {
    name = "nixup";
    src = ./nixup.sh;
    nix = config.nix.package or pkgs.nix;
  };

in

{
  config = {
    user.packages =
      [ nixup
      ];

    nixup.build = {
      inherit nixup;
    };
  };
}
