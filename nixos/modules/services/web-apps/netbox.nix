{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.netbox;

  netbox = pkgs.netbox;
  gunicorn = pkgs.python3Packages.gunicorn;
  python = pkgs.python3Packages.python;

  dataDir = cfg.dataDir;
  staticDir = cfg.dataDir + "/static";

  #pythonEnv = pkgs.python3.withPackages (ps: with ps;
  #  [ netbox ]);

  netbox-config = pkgs.writeText "configuration.py" ''
    STATIC_ROOT = '${staticDir}'

    ALLOWED_HOSTS = ['*']

    DATABASE = {
      'NAME': 'netbox',
      'USER': 'netbox',
      'HOST': '/run/postgresql',
    }

    # Redis database settings. Redis is used for caching and for queuing background tasks such as webhook events. A separate
    # configuration exists for each. Full connection details are required in both sections, and it is strongly recommended
    # to use two separate database IDs.
    REDIS = {
        'tasks': {
            'HOST': 'localhost',
            'PORT': 6379,
            # Comment out `HOST` and `PORT` lines and uncomment the following if using Redis Sentinel
            # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
            # 'SENTINEL_SERVICE': 'netbox',
            'DATABASE': 0,
            'SSL': False,
        },
        'caching': {
            'HOST': 'localhost',
            'PORT': 6379,
            # Comment out `HOST` and `PORT` lines and uncomment the following if using Redis Sentinel
            # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
            # 'SENTINEL_SERVICE': 'netbox',
            'DATABASE': 1,
            'SSL': False,
        }
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

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/netbox";
        description = "Storage path of netbox.";
      };

    };
  };

  config = mkIf cfg.enable {
    environment.etc."netbox/configuration.py".source = netbox-config;
    services.redis.enable = true;

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "netbox" ];
      ensureUsers = [
        {
          name = "netbox";
          ensurePermissions = {
            "DATABASE netbox" = "ALL PRIVILEGES";
          };
        }
      ];
    };


    systemd.services.netbox = {
      description = "netbox";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment.PYTHONPATH = let
        py = pkgs.python3.override {
          packageOverrides = self: super: {
            django = super.django_3;
          };
        };

      in "${pkgs.python3.withPackages (p: [
        py.pkgs.django_3
        py.pkgs.django-cacheops
        py.pkgs.django-cors-headers
        py.pkgs.django-debug-toolbar
        py.pkgs.django-filter
        py.pkgs.django-mptt
        py.pkgs.django-pglocks
        py.pkgs.django-prometheus
        py.pkgs.django-rq
        py.pkgs.django-tables2
        py.pkgs.django_taggit
        py.pkgs.django-timezone-field
        py.pkgs.djangorestframework
        py.pkgs.drf-yasg
        py.pkgs.gunicorn
        py.pkgs.jinja2
        py.pkgs.markdown
        py.pkgs.netaddr
        py.pkgs.pillow
        py.pkgs.psycopg2
        py.pkgs.pycryptodome
        py.pkgs.pyyaml
        py.pkgs.svgwrite
      ])}/${pkgs.python3.sitePackages}";

      script = ''
        ${pkgs.python3}/bin/python3 ${pkgs.netbox}/opt/netbox/netbox/manage.py migrate
        ${pkgs.python3}/bin/python3 ${pkgs.netbox}/opt/netbox/netbox/manage.py trace_paths --no-input
        ${pkgs.python3}/bin/python3 ${pkgs.netbox}/opt/netbox/netbox/manage.py collectstatic --no-input
        ${pkgs.python3}/bin/python3 ${pkgs.netbox}/opt/netbox/netbox/manage.py remove_stale_contenttypes --no-input
        ${pkgs.python3}/bin/python3 ${pkgs.netbox}/opt/netbox/netbox/manage.py clearsessions
        ${pkgs.python3}/bin/python3 ${pkgs.netbox}/opt/netbox/netbox/manage.py invalidate all
        ${pkgs.python3Packages.gunicorn}/bin/gunicorn --bind ${cfg.listenAddress}:${toString cfg.port} --pythonpath ${pkgs.netbox}/opt/netbox/netbox netbox.wsgi
        '';

      serviceConfig = {
        User = "netbox";
        Group = "netbox";
      };
    };

    users.users.netbox = {
      #group = "netbox";
      home = "${cfg.dataDir}";
      createHome = true;
      isSystemUser = true;
    };

    users.groups.netbox.members = [ "netbox" ];
  };
}
