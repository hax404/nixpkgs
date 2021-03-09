{ lib, python3, python3Packages, fetchFromGitHub }:

let
  py = python3.override {
    packageOverrides = self: super: {
      django = super.django_3;
    };
  };
in
with py.pkgs;

python3Packages.buildPythonApplication rec {
  pname = "netbox";
  version = "2.10.6";
  format = "other";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = pname;
    rev = "v${version}";
    sha256 = "0sx9ziq0qw9kgcqjhkyq5b0g4c3v70bj2n364b300mfz7c4iflfv";
  };

  #buildInputs = with pythonPackages; [
  #  python3Packages.py_stringmatching
  #];

  propagatedBuildInputs = with py.pkgs; [
    django_3
    django-cacheops
    django-cors-headers   ###
    django-debug-toolbar      # https://github.com/NixOS/nixpkgs/pull/55033
    django-filter     ###
    django-mptt       #       (https://github.com/NixOS/nixpkgs/issues/46317)
    django-pglocks    ###
    django-prometheus
    django-rq                 # https://github.com/NixOS/nixpkgs/pull/88962
    django-tables2            # https://github.com/NixOS/nixpkgs/pull/63692/files#diff-98e352e7fc738333e16cee9651fa0411a97b444989d926f64a505409ee46cd27
    django_taggit   ###
    django-timezone-field
    djangorestframework    ###
    drf-yasg  ###
    gunicorn
    jinja2
    markdown
    netaddr
    pillow
    psycopg2
    pycryptodome
    pyyaml
    svgwrite
  ];

  #env = propagatedBuildInputs (_: [ propagatedBuildInputs ]);

  dontBuild = true;

  installPhase = ''
    # ls -la $out/opt/netbox
    install -d $out/opt/netbox/
    cp -r * $out/opt/netbox/
    ls -la $out/opt/netbox
    # FIXME: The configuration should be located in the nix-store
    ln -s /etc/netbox/configuration.py $out/opt/netbox/netbox/netbox/configuration.py
  '';

  meta = with lib; {
    homepage = "https://github.com/netbox-community/netbox";
    description = "IP address management (IPAM) and data center infrastructure management (DCIM) tool.";
    license = licenses.asl20;
    maintainers = with maintainers; [ hax404 ];
  };
}
