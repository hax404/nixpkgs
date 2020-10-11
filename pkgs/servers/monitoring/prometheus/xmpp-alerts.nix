{ lib, fetchFromGitHub, pythonPackages }:

pythonPackages.buildPythonApplication rec {
  pname = "prometheus-xmpp-alerts";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "jelmer";
    repo = pname;
    rev = version;
    sha256 = "0hbhfx9k3rnhxc74idw8mnnv59w83mdq94m1x8hap8n9sc953idi";
  };

  nativeBuildInputs = [ pythonPackages.pytz ];

  propagatedBuildInputs = with pythonPackages; [ aiohttp slixmpp prometheus_client pyyaml ];

  meta = {
    description = "XMPP Web hook for Prometheus";
    homepage = "https://github.com/jelmer/prometheus-xmpp-alerts";
    maintainers = with lib.maintainers; [ fpletz ];
    license = with lib.licenses; [ asl20 ];
  };
}
