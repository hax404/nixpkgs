{ lib, buildPythonPackage, fetchPypi, django }:

buildPythonPackage rec {
  pname = "django-js-asset";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0q3j2rsdb2i7mvncy9z160cghcggvk87q14qnn7jvcp0sa0awqy1";
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

