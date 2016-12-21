{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonAtLeast
}:

let
  version = "1.1.6";
in
buildPythonPackage rec {
  name = "enum34-${version}";

  src = fetchPyPi {
    package = "enum34";
    inherit version;
    sha256 = "8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1";
  };

  # Python 3.4 Enum backported to 2.4 through 3.3
  disabled = pythonAtLeast "3.4";
  doCheck = true;

  meta = with lib; {
    description = "Python 3.4 Enum backported to 2.4 through 3.3";
    homepage = https://bitbucket.org/stoneleaf/enum34;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
