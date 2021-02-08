{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.uptermd;
in
{
  options = {
    services.uptermd = {
      enable = mkEnableOption "uptermd";

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open the firewall for the port in <option>services.uptermd.port</option>.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 2222;
        description = ''
          Port the server will listen on. A port lower than 1024 will add the CAP_NET_BIND_SERVICE capability to the service.
        '';
      };

      listenAddress = mkOption {
        type = types.str;
        default = "[::]";
        example = "127.0.0.1";
        description = ''
          Address the server will listen on.
        '';
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "--debug" ];
        description = ''
          Extra flags passed to the uptermd command.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.uptermd = {
      description = "Upterm Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.upterm ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.upterm}/bin/uptermd --ssh-addr ${cfg.listenAddress}:${toString cfg.port} ${concatStringsSep " " cfg.extraFlags}";

        # Hardening
        AmbientCapabilities = mkIf cfg.port < 1024 "CAP_NET_BIND_SERVICE";
        PrivateUsers = if cfg.port < 1024 then false else true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        ProtectControlGroups = true;
        ProtectClock = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
      };
    };
  };
}
