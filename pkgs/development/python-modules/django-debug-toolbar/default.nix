# https://github.com/NixOS/nixpkgs/pull/55033
{ lib, buildPythonPackage, fetchPypi, django, sqlparse }:

buildPythonPackage rec {
  pname = "django-debug-toolbar";
  version = "3.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1lk134s0gd7ymq2rikkxg3xqw23wnj0g7b52y0fmgg8dj1yn1ql4";
  };

  # django.core.exceptions.ImproperlyConfigured (path issue with DJANGO_SETTINGS_MODULE?)
  doCheck = false;

  propagatedBuildInputs = [ django sqlparse ];

  meta = with lib; {
    description = "Configurable set of panels that display various debug information";
    homepage = https://github.com/jazzband/django-debug-toolbar;
    maintainers = with maintainers; [ peterromfeldhk ];
    license = with licenses; [ bsd3 ]; # not sure what license that is
  };
}
