{ lib, stdenv
, fetchFromGitHub
, rustPlatform
, libgpgerror
, gpgme
, libxcb
, python3
}:
rustPlatform.buildRustPackage rec {
  pname = "gpg-tui";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "orhun";
    repo = pname;
    rev = "v${version}";
    sha256 = "1hg8a1vxrkl2737dhb46ikzhnfz87zf9pvs370l9j8h7zz1mcq66";
  };

  cargoSha256 = "00azv55r4ldpr6gfn77ny9rzm3yqlpimvgzx2cwkwnhgmfcq2l1j";

  nativeBuildInputs = [
    libgpgerror
    gpgme
    python3
  ];

  buildInputs = [
    libxcb
  ];

}
