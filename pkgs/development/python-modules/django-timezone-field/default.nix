{ lib, buildPythonPackage, fetchPypi, django }:

buildPythonPackage rec {
  pname = "django-timezone-field";
  version = "4.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1pxrs6mkayr2rqxj8q4wdfrdhw1dnzvwkacajdjy6q6ha8jcdyng";
  };

  # django.core.exceptions.ImproperlyConfigured (path issue with DJANGO_SETTINGS_MODULE?)
  doCheck = false;

  propagatedBuildInputs = [ django ];

  meta = with lib; {
    #description = "Configurable set of panels that display various debug information";
    #homepage = https://github.com/jazzband/django-cacheops;
    #maintainers = with maintainers; [ peterromfeldhk ];
    #license = with licenses; [ bsd3 ]; # not sure what license that is
  };
}

