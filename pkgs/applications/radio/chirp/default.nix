{ stdenv
, fetchhg
, gettext
, python3
}:
python3.pkgs.buildPythonApplication rec {
  pname = "chirp";
  version = "20191221";

  src = fetchhg {
    url = "http://d-rats.com/hg/chirp.hg";
    rev = "py3";
    sha256 = "08ynxf21v3f6f7pz18znxspgwhkwjjljxx2d1f3xhwcyr0nxalfr";

  };

  patches = [
    ./patches/locale-makefile.patch
    ./patches/chirp-ui-mainapp.py.patch
    ./patches/chirp-drivers-kguv8dplus.py.patch
    ./patches/chirp-drivers-ftm350.py.patch
  ];

    #with python3.pkgs; [
    #python37Packages.
  propagatedBuildInputs = [
    python3.pkgs.pyserial
    python3.pkgs.libxml2
    python3.pkgs.future
    python3.pkgs.six
    gettext
  ];

  meta = with stdenv.lib; {
    description = "A free, open-source tool for programming your amateur radio";
    homepage = https://chirp.danplanet.com/;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.the-kenny ];
  };
}
