{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.upmpdcli;

  defaultConf = {
    # upnp network parameters
    ##upnpiface =
    upnpip = "127.0.0.1";
    upnpport = 49152; # libupnp/pupnp defaults to using the first free port after 49152. Note that clients do not need to know about the value, which is automatically discovered.

    ## media renderer parameters
    friendlyname = "UpMpd";
    upnpav = 1;
    openhome = 0;
    ##lumincompat = 0
    ##saveohcredentials = 1
    ##checkcontentformat = 1
    ##iconpath = /usr/share/upmpdcli/icon.png
    ##cachedir = /var/cache/upmpdcli
    ##presentationhtml = /usr/share/upmpdcli/presentation.html

    ## mpd parameters
    mpdhost = "127.0.0.1";
    mpdport = 6600;
    ##mpdpassword =
    ##ownqueue = 1
  };

  configuration =
    defaultConf
    // {
      ### https://www.lesbonscomptes.com/upmpdcli/upmpdcli-manual.html#UPMPDCLI-CONFIGURATION
      pkgdatadir = "${pkgs.upmpdcli}/share/upmpdcli";

    }
    // cfg.configuration;

  format = pkgs.formats.keyValue { };

  upmpdcliConf = format.generate "upmpdcli.conf" configuration;
in
{

  options = {

    services.upmpdcli = {

      enable = lib.mkEnableOption "upmpdcli, a music player daemon";

      configuration = lib.mkOption {
        description = ''
          Key-value pairs that convey parameters about the configuration
        '';
        default = defaultConf;
        type = lib.types.submodule {
          freeformType = (pkgs.formats.keyValue { }).type;
          options = {
            upnpip = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              example = "0.0.0.0";
              description = "The address listening for incoming UPnP connections.";
            };

            upnpport = lib.mkOption {
              type = lib.types.port;
              default = 49152;
              description = "The port listening for incoming UPnP connections.";
            };

            #...
          };
        };
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.packages = [ pkgs.upmpdcli ];
    systemd.services.upmpdcli.serviceConfig = {
      ExecStart = "${pkgs.upmpdcli}/bin/upmpdcli -c ${upmpdcliConf}";
      DynamicUser = true;
    };
  };

}
