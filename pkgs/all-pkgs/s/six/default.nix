{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.12.0";
in
buildPythonPackage rec {
  name = "six-${version}";

  src = fetchPyPi {
    package = "six";
    inherit version;
    sha256 = "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73";
  };

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Python 2 and 3 compatibility utilities";
    homepage = https://bitbucket.org/gutworth/six;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
