{ lib
, stdenv
, fetchFromGitHub
, cmake
, mkDerivation
, qtbase
, qttools
, qtserialport
, qtlocation
, libusb
, pkg-config
}:

mkDerivation rec {
  pname = "qdmr";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "hmatuschek";
    repo = pname;
    rev = "v${version}";
    sha256 = "1wa8xfiqrfks9vw2mwryjvkks28wajx2b6k8wbmd6i1gjkj626cb";
  };

  #patchPhase = ''
  #  sed -i "s/'/etc'/'${CMAKE_INSTALL_PREFIX}/lib'/
  #'';

  postPatch = ''
    substituteInPlace lib/CMakeLists.txt --replace "/etc/udev/rules.d" "$out/etc/udev/rules.d"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    qtbase
    qttools
    qtserialport
    qtlocation
    libusb
  ];

  meta = with lib; {
    #description = "Desktop client for the Matrix protocol";
    #homepage = "https://github.com/Nheko-Reborn/nheko";
    #maintainers = with maintainers; [ ekleog fpletz ];
    platforms = platforms.all;
    license = licenses.gpl3;
  };

}
