# https://github.com/NixOS/nixpkgs/pull/88962/

{ lib, fetchPypi, buildPythonPackage, redis, rq, django_3 }:

buildPythonPackage rec {
  pname = "django-rq";
  version = "2.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0v8zgsnfziy0i55ir3cz4hc6x9x8jpk6l5brs4yg32rmcpmz8l9q";
  };

  # test require a running redis rerver, which is something we can't do yet
  doCheck = false;

  propagatedBuildInputs = [ rq django_3 redis ];

  meta = with lib; {
    description = "A simple app that provides django integration for RQ (Redis Queue)";
    homepage = "https://github.com/rq/django-rq";
    maintainers = with maintainers; [ winpat ];
    license = licenses.mit;
  };
}
