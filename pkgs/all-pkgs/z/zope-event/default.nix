{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.4";
in
buildPythonPackage rec {
  name = "zope.event-${version}";

  src = fetchPyPi {
    package = "zope.event";
    inherit version;
    sha256 = "69c27debad9bdacd9ce9b735dad382142281ac770c4a432b533d6d65c4614bcf";
  };

  meta = with lib; {
    description = "An event publishing system";
    homepage = https://pypi.python.org/pypi/zope.event;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
