{ lib, buildPythonPackage, fetchPypi, django, six, redis, funcy }:

buildPythonPackage rec {
  pname = "django-cacheops";
  version = "5.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1pcr1z55pdr5f89dyvzxxl706mcgvgfsikyf3x53i1rhpzbir1fm";
  };

  # django.core.exceptions.ImproperlyConfigured (path issue with DJANGO_SETTINGS_MODULE?)
  doCheck = false;

  propagatedBuildInputs = [ django six redis funcy ];

  meta = with lib; {
    #description = "Configurable set of panels that display various debug information";
    #homepage = https://github.com/jazzband/django-cacheops;
    #maintainers = with maintainers; [ peterromfeldhk ];
    #license = with licenses; [ bsd3 ]; # not sure what license that is
  };
}

