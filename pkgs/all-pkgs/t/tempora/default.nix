{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
, setuptools-scm
, six
}:

let
  version = "1.7";
in
buildPythonPackage rec {
  name = "tempora-${version}";

  src = fetchPyPi {
    package = "tempora";
    inherit version;
    sha256 = "a264672b7f39198eb90b531490ade4e873f6e13839253636c3bd6a5549be1984";
  };

  propagatedBuildInputs = [
    pytz
    setuptools-scm
    six
  ];

  meta = with lib; {
    description = "Objects and routines pertaining to date and time";
    homepage = https://github.com/jaraco/tempora;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
