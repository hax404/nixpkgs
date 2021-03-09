{ lib, buildPythonPackage, fetchPypi, django, django-js-asset }:

buildPythonPackage rec {
  pname = "django-mptt";
  version = "0.12.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0fpi263gfslq6fxdzk6vx75in6vpy1xy53ck5yxjkd97261c7rla";
  };

  # django.core.exceptions.ImproperlyConfigured (path issue with DJANGO_SETTINGS_MODULE?)
  doCheck = false;

  propagatedBuildInputs = [ django django-js-asset ];

  meta = with lib; {
    #description = "Configurable set of panels that display various debug information";
    #homepage = https://github.com/jazzband/django-cacheops;
    #maintainers = with maintainers; [ peterromfeldhk ];
    #license = with licenses; [ bsd3 ]; # not sure what license that is
  };
}

