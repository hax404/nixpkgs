{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "spicetify-cli";
  version = "2.8.2";

  src = fetchFromGitHub {
    owner = "khanhas";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-YMVB9nKsHYy65McYs1w/ETy+1b8GkjuWFk6PZs4HFko=";
  };

  vendorSha256 = "sha256-g0RYIVIq4oMXdRZDBDnVYg7ombN5WEo/6O9hChQvOYs=";

  # used at runtime, but not installed by default
  postInstall = ''
    cp -r ${src}/jsHelper $out/bin/jsHelper
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/spicetify-cli --help > /dev/null
  '';

  meta = with lib; {
    description = "Command-line tool to customize Spotify client";
    homepage = "https://github.com/khanhas/spicetify-cli/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ jonringer ];
  };
}
