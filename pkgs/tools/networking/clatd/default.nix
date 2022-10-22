{ lib
, stdenv
, fetchFromGitHub
, perlPackages
, makeWrapper
, tayga
, iproute2
, iptables
, nixosTests
}:

stdenv.mkDerivation rec {
  version = "1.5";
  pname = "clatd";

  src = fetchFromGitHub {
    owner = "toreanderson";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-P3WOF6FKf7+ANOw6QQ3VE46rTAc5aGHgUu8OV4i0/2A=";
  };

  passthru.tests.clatd = nixosTests.clatd;

  buildInputs = [ perlPackages.perl ];
  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace clatd \
      --replace \"ip\" \"${iproute2}/bin/ip\" \
      --replace \"ip6tables\" \"${iptables}/bin/ip6tables\" \
      --replace \"tayga\" \"${tayga}/bin/tayga\"
  '';

  dontBuild = true;

  installPhase = ''
    install -D clatd $out/bin/clatd
    mkdir -p $out/share/man/man8
    pod2man --name clatd --center "clatd - a CLAT implementation for Linux" --section 8 --release ${version} README.pod > $out/share/man/man8/clatd.8

    wrapProgram $out/bin/clatd \
      --prefix PERL5LIB : "${with perlPackages; makePerlPath [ NetIP IOSocketInet6 Socket6 NetDNS ]}"
  '';

  meta = with lib; {
    description = "A CLAT / SIIT-DC Edge Relay implementation for Linux";
    homepage = "https://github.com/toreanderson/clatd";
    license = licenses.mit;
    maintainers = with maintainers; [ hax404 ];
  };
}
