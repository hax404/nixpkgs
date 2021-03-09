{ lib, buildPythonPackage, fetchPypi, django, pytestrunner, prometheus_client }:

buildPythonPackage rec {
  pname = "django-prometheus";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1wj32rw9lh4fbwr1qa24n63f5bfi4dm55l80bkpznh4i76hqsgyx";
  };

  # django.core.exceptions.ImproperlyConfigured (path issue with DJANGO_SETTINGS_MODULE?)
  doCheck = false;

  propagatedBuildInputs = [ django pytestrunner prometheus_client ];

  meta = with lib; {
    #description = "Configurable set of panels that display various debug information";
    #homepage = https://github.com/jazzband/django-cacheops;
    #maintainers = with maintainers; [ peterromfeldhk ];
    #license = with licenses; [ bsd3 ]; # not sure what license that is
  };
}

