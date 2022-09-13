import ./make-test-python.nix ({ pkgs, lib, ... }: {
  name = "pixelfed";
  meta.maintainers = [ lib.maintainers.raitobezarius ];

  nodes.machine =
    { ... }:
    {
      services.pixelfed = {
        enable = true;
        domain = "localhost";
        mutableSettings = true;
        settings.APP_KEY = "ec0e34381688562df3f377fdbb77a3247b3d10bdffbe4aed59ea9f2ca950e8b8";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };

  testScript = ''
    start_all()

    machine.wait_for_unit("pixelfed-data-setup.service")
    machine.wait_for_unit("phpfpm-pixelfed.service")
    machine.wait_for_unit("nginx.service")
    machine.wait_for_unit("pixelfed-horizon.service")

    machine.wait_for_open_port(80)

    print(machine.succeed("curl http://localhost"))
  '';
})
