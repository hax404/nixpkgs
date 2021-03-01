{ lib, rustPlatform, fetchFromGitHub, llvmPackages, pkgconfig, openssl, glib, libnice }:

rustPlatform.buildRustPackage rec {
  pname = "mumble-web-proxy";
  version = "git";

  src = fetchFromGitHub {
    owner = "johni0702";
    repo = pname;
    rev = "cfae6178c70c1436186f16723b18a2cbb0f06138";
    sha256 = "0l194xida852088l8gv7v2ygjxif46fhzp18dvv19i7wssgq8jkf";
  };

  cargoSha256 = "0nsy3m53rk51g2x2j55zscl63ap1z2hhh6dazpvajj1hch6wkln0";

  buildInputs = [ openssl glib llvmPackages.libclang libnice.dev ];
  nativeBuildInputs = [ pkgconfig ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  RUSTFLAGS="-L ${libnice.dev}/include";
  PKG_CONFIG_PATH="${libnice.dev}/include";

  meta = with stdenv.lib; {
    description = "";
    homepage = "https://github.com/johni0702/mumble-web-proxy";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.hax404 ];
  };
}

