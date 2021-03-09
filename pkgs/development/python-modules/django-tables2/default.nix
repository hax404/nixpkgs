# https://github.com/NixOS/nixpkgs/pull/63692/files#diff-98e352e7fc738333e16cee9651fa0411a97b444989d926f64a505409ee46cd27

{ lib, buildPythonPackage, fetchPypi, django_3 }:

buildPythonPackage rec {
  pname = "django-tables2";
  version = "2.3.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "18ppbqgk8zjkc602gv5ms1f78d01z1718ksdi9nrj2kl2fysvk2h";
  };

  propagatedBuildInputs = [ django_3 ];

  # test files not included in package
  doCheck = false;

  meta = with lib; {
    description = "An app for creating HTML tables";
    homepage = "https://django-tables2.readthedocs.io/en/latest/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ gerschtli ];
  };
}
