{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.pixelfed;

  user = cfg.user;
  group = cfg.group;

  pixelfed = cfg.package.override {
    dataDir = cfg.dataDir;
  };

  settingsFormat = pkgs.formats.keyValue {
    listToValue = xs: ''"${concatStringsSep ", " (map toString xs)}"'';
  };
  environmentFile = settingsFormat.generate "pixelfed.env" cfg.settings;

  pixelfed-artisan = pkgs.writeShellScriptBin "pixelfed-artisan" ''
    cd ${pixelfed}
    sudo=exec
    if [[ "$USER" != ${user} ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${user}'
    fi
    $sudo ${cfg.phpPackage}/bin/php artisan $*
  '';


in {
  options.services = {
    pixelfed = {
      enable = mkEnableOption (lib.mdDoc "the pixelfed service");

      package = mkPackageOption pkgs "pixelfed" {};

      user = mkOption {
        default = "pixelfed";
        description = lib.mdDoc ''
          User account under which pixelfed runs.
        '';
      };
      group = mkOption {
        default = "pixelfed";
        description = lib.mdDoc ''
          Group account under which pixelfed runs.
        '';
      };

      domain = mkOption {
        type = types.str;
        description = lib.mdDoc ''
          FQDN for the pixelfed instance.
        '';
      };

      mutableSettings = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          FIXME
        '';
      };

      settings = mkOption {
        type = settingsFormat.type;
        description = lib.mdDoc ''
          Settings for pixelfed.
        '';
      };

      appKeyFile = mkOption {
        type = types.str;
        description = lib.mdDoc ''
          A random 32-character string to be used as an encryption key. No default value;
          use php artisan key:generate in the dataDir to generate. '';
      };

      maxUploadSize = mkOption {
        type =  types.ints.positive;
        default = 8;
        description = lib.mdDoc ''
          Max upload size in megabytes.
        '';
      };


      nginx.enableACME = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
        Whether or not to enable ACME and let's encrypt for the pixelfed vhost.
      '';
      };

      poolSettings = mkOption {
        type = with types; attrsOf (oneOf [ int str bool ]);
        default = {
          "pm" = "dynamic";
          "php_admin_value[error_log]" = "stderr";
          "php_admin_flag[log_errors]" = true;
          "catch_workers_output" = true;
          "pm.max_children" = "32";
          "pm.start_servers" = "2";
          "pm.min_spare_servers" = "2";
          "pm.max_spare_servers" = "4";
          "pm.max_requests" = "500";
        };

        description = lib.mdDoc ''
           Options for Pixelfed's PHP pool. See the documentation on `php-fpm.conf` for details on configuration directives.
        '';
      };

      phpPackage = mkPackageOption pkgs "PHP package" {
        default = "php80";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/pixelfed";
        description = lib.mdDoc ''
          Home directory of the `pixelfed` user which holds the application's state.
        '';
      };

    };
  };


  config = mkIf cfg.enable {
    environment.systemPackages = [ pixelfed-artisan ];

    services.pixelfed.settings = {
      # Mutable .env
      ENABLE_CONFIG_CACHE = false; # TODO: remove me when https://github.com/pixelfed/pixelfed/issues/4010 lands ; cfg.mutableSettings;

      APP_DEBUG = lib.mkDefault false;

      APP_URL = lib.mkDefault "http://${cfg.domain}";
      APP_DOMAIN = lib.mkDefault cfg.domain;
      ADMIN_DOMAIN = lib.mkDefault cfg.domain;
      TRUST_PROXIES = lib.mkDefault [ "127.0.0.1/8" "::1/128" ];

      OPEN_REGISTRATION = lib.mkDefault false;

      DB_CONNECTION = lib.mkDefault "mysql";
      DB_SOCKET = lib.mkDefault "/run/mysqld/mysqld.sock";
      DB_PORT = lib.mkDefault 0;
      DB_DATABASE = lib.mkDefault "pixelfed";
      DB_USERNAME = lib.mkDefault "pixelfed";

      REDIS_SCHEME = lib.mkDefault "unix";
      # For predis driver, the default, REDIS_PATH is the right variable.
      # For phpredis driver, REDIS_HOST is the right variable.
      REDIS_PATH = lib.mkDefault config.services.redis.servers.pixelfed.unixSocket;
      REDIS_PORT = lib.mkDefault 0;

      ACTIVITY_PUB = lib.mkDefault true;
      AP_REMOTE_FOLLOW = lib.mkDefault true;
      OAUTH_ENABLED = lib.mkDefault true;

      IMAGE_DRIVER = lib.mkDefault "imagick";
      CACHE_DRIVER = lib.mkDefault "redis";
      QUEUE_DRIVER = lib.mkDefault "redis";
      BROADCAST_DRIVER = lib.mkDefault "redis";

      MAIL_DRIVER = lib.mkDefault "log";
    };

    users.users.pixelfed = mkIf (cfg.user == "pixelfed") {
      isSystemUser = true;
      group = cfg.group;
      extraGroups = [ config.services.redis.servers.pixelfed.user ];
      home = cfg.dataDir;
    };

    users.groups.pixelfed = mkIf (cfg.group == "pixelfed") {};

    services.phpfpm.pools.pixelfed = {
      inherit (cfg) phpPackage user group;

      phpOptions = ''
        post_max_size = ${toString cfg.maxUploadSize}M
        upload_max_filesize = ${toString cfg.maxUploadSize}M
        max_execution_time = 600;
      '';

      settings = {
        inherit user group;
        "listen.owner" = "nginx";
        "listen.group" = "nginx";
        "listen.mode" = "0660";
      } // cfg.poolSettings;

    };

    services.redis.servers.pixelfed = {
      enable = true;
      unixSocketPerm = 770;
    };

    services.mysql = {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
      ensureUsers = [ {
        name = "pixelfed";
        ensurePermissions = {
          "pixelfed.*" = "ALL PRIVILEGES";
        };
      } ];
      ensureDatabases = [ "pixelfed" ];
    };

    systemd.services.pixelfed-data-setup = {
      description = "Setup dataDir for pixelfed and change permissions";

      wantedBy = [ "multi-user.target" ];

      after = [ "mysql.service" "redis-pixelfed.service" ];
      requires = [ "mysql.service" "redis-pixelfed.service" ];

      path = [ pixelfed-artisan ];

      serviceConfig = {
        User = user;
        Group = group;
        WorkingDirectory = cfg.dataDir;
      };

      script = ''
        ${if cfg.mutableSettings then
          "[ ! -f ${cfg.dataDir}/.env ] && cp ${environmentFile} ${cfg.dataDir}/.env"
          else "ln -sf ${environmentFile} '${cfg.dataDir}/.env'"}

        ${optionalString cfg.mutableSettings "pixelfed-artisan config:cache"}

        pixelfed-artisan storage:link
        pixelfed-artisan import:cities

        ${optionalString true "pixelfed-artisan instance:actor"}
        ${optionalString true "pixelfed-artisan passport:keys"}

        pixelfed-artisan migrate --force
        pixelfed-artisan route:cache
        pixelfed-artisan view:cache
      '';
    };

    systemd.services.pixelfed-horizon = {
      description = "Pixelfed task queueing via Laravel Horizon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "phpfpm-pixelfed.service"
        "redis-pixelfed.service"
        "nginx.service"
        "mysql.service"
      ];

      path = [ pixelfed-artisan ];

      serviceConfig = {
        ExecStart = "${pixelfed-artisan}/bin/pixelfed-artisan horizon";
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0710 ${user} ${group} - -"
      "d ${cfg.dataDir}/bootstrap                  0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/bootstrap/cache            0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage                    0755 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app                0755 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/backups        0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public         0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public/avatars 0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public/emoji   0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public/headers 0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public/live-hls 0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public/m       0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/public/textimg 0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app/remcache       0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/debugbar           0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework          0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/cache    0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/sessions 0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/views    0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/testing  0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/logs               0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/purify             0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/uploads            0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/private_uploads    0700 ${user} ${group} - -"
    ];

    services.nginx.enable = true;
    services.nginx.virtualHosts."${cfg.domain}" = mkMerge [
        { root = "${pixelfed}/public/";
          locations."/".extraConfig = ''
            try_files $uri $uri/ /index.php?$query_string;
          '';
          locations."/favicon.ico".extraConfig = ''
            access_log off; log_not_found off;
          '';
          locations."/robots.txt".extraConfig = ''
            access_log off; log_not_found off;
          '';
          locations."~ \\.php$".extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.pixelfed.socket}; # make sure this is correct
            fastcgi_index index.php;
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            include ${config.services.nginx.package}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; # or $request_filename
          '';
          locations."~ /\\.(?!well-known).*".extraConfig = ''
            deny all;
          '';
          extraConfig = ''
              client_max_body_size ${toString cfg.maxUploadSize}M;
              add_header X-Frame-Options "SAMEORIGIN";
              add_header X-XSS-Protection "1; mode=block";
              add_header X-Content-Type-Options "nosniff";
              index index.html index.htm index.php;
              error_page 404 /index.php;
          '';
        }
        (mkIf cfg.nginx.enableACME {
          enableACME = true;
        })
      ];
  };
}
