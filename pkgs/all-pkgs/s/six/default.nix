{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.14.0";
in
buildPythonPackage rec {
  name = "six-${version}";

  src = fetchPyPi {
    package = "six";
    inherit version;
    sha256 = "236bdbdce46e6e6a3d61a337c0f8b763ca1e8717c03b369e87a7ec7ce1319c0a";
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
