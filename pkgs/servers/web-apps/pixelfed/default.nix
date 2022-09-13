{ lib
, stdenv
, fetchFromGitHub
, php
, pkgs
}:

let
  package = (import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    noDev = true; # Disable development dependencies
  });
in package.override rec {
  pname = "pixelfed";
  version = "0.11.4";

  # GitHub distribution does not include vendored files
  src = fetchFromGitHub {
    owner = "pixelfed";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-16RD2L2Ai0gsrmdiY9PzXJEBytip/o/hc6WiWONjWE8=";
  };

  meta = with lib; {
    description = "A federated image sharing platform";
    license = licenses.agpl3Only;
    homepage = "https://pixelfed.org/";
    maintainers = with maintainers; [ raitobezarius ];
    inherit (php.meta) platforms;
  };
}
