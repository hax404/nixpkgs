{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.netbox;

  netbox-config = pkgs.writeText "configuration.py" ''
    ALLOWED_HOSTS = ['*']

    DATABASE = {
      'NAME': 'netbox',
      'USER': 'netbox',
      'HOST': 'localhost',
    }

    SECRET_KEY = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  '';
in
{
  options = {
    services.netbox = {
      enable = mkEnableOption "Netbox";

      listenAddress = mkOption {
        type = types.str;
        default = "[::1]";
        description = ''
          Address the server will listen on.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 8001;
        description = ''
          Port the server will listen on.
        '';
      };

    };
  };

  config = mkIf cfg.enable {
    environment.etc."netbox/configuration.py".target = cfg.netbox-config;
    systemd.services.netbox = {
      description = "netbox";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.python3Packages.gunicorn}/bin/gunicorn --bind ${cfg.listenAddress}:${toString cfg.port} --pythonpath ${pkgs.netbox}/opt/netbox/netbox netbox.wsgi";
      };
    };
  };
}
