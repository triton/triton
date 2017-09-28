{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.11.0";
in
buildPythonPackage rec {
  name = "six-${version}";

  src = fetchPyPi {
    package = "six";
    inherit version;
    sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9";
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
