{ lib
, stdenv
, fetchFromGitHub
, php
, pkgs
, dataDir ? "/var/lib/pixelfed"
}:

let
  package = (import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    noDev = true; # Disable development dependencies
  }).overrideAttrs (attrs : {
    installPhase = attrs.installPhase + ''
      rm -R $out/bootstrap/cache $out/storage
      ln -s ${dataDir}/.env $out/.env
      ln -s ${dataDir}/storage $out/
      ln -s ${dataDir}/storage/app/public $out/public/storage
      ln -s ${dataDir}/bootstrap/cache $out/bootstrap/cache
      chmod +x $out/artisan
    '';
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
