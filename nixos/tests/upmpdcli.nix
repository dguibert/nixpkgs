{ lib, ... }:

{
  name = "upmpdcli";
  meta.maintainers = with lib.maintainers; [ ];

  nodes.machine =
    { pkgs, ... }:
    {
      services.upmpdcli.enable = true;
    };

  testScript = ''
    machine.wait_for_unit("upmpdcli.service")
  '';
}
