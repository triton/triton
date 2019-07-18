{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "7.0.0";
in
buildPythonPackage rec {
  name = "aniso8601-${version}";

  src = fetchPyPi {
    package = "aniso8601";
    inherit version;
    sha256 = "513d2b6637b7853806ae79ffaca6f3e8754bdd547048f5ccc1420aec4b714f1e";
  };

  meta = with lib; {
    description = "A library for parsing ISO 8601 strings";
    homepage = https://bitbucket.org/nielsenb/aniso8601;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
