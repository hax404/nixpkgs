{ lib, stdenv, fetchFromGitHub, fuse, boost, gcc, icu, libzip, pandoc
, pkg-config }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mount-zip";
  version = "1.0.14";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mount-zip";
    rev = "v${finalAttrs.version}";
    hash = "sha256-S2snseC9JAjYRberL2/CyRQTcZQ8GtGQNU3WuTqSRl4=";
  };

  nativeBuildInputs = [ boost gcc icu pandoc pkg-config ];
  buildInputs = [ fuse libzip ];

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "FUSE file system for ZIP archives";
    homepage = "https://github.com/google/mount-zip";
    longDescription = ''
      mount-zip is a tool allowing to open, explore and extract ZIP archives.

      This project is a fork of fuse-zip.
    '';
    license = licenses.gpl3;
    maintainers = with maintainers; [ arti5an ];
    platforms = platforms.linux;
    mainProgram = "mount-zip";
  };
})
