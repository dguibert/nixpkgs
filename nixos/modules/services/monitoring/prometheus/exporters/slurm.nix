{ config, lib, pkgs, options }:

with lib;

let
  cfg = config.services.prometheus.exporters.slurm;
in
{
  port = 8080;
  extraOpts = {
    logFormat = mkOption {
      type = types.str;
      default = "logger:stderr";
      example = "logger:syslog?appname=bob&local=7 or logger:stdout?json=true";
      description = ''
        Set the log target and format.
      '';
    };

    logLevel = mkOption {
      type = types.enum ["debug" "info" "warn" "error" "fatal"];
      default = "info";
      description = ''
        Only log messages with the given severity or above.
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-slurm-exporter}/bin/prometheus-slurm-exporter \
          -log.format ${cfg.logFormat} \
          -log.level ${cfg.logLevel} \
          -listen-address ${cfg.listenAddress}:${toString cfg.port}
      '';
    };
  };
}
