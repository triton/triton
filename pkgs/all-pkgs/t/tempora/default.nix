{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
, setuptools-scm
, six
}:

let
  version = "1.9";
in
buildPythonPackage rec {
  name = "tempora-${version}";

  src = fetchPyPi {
    package = "tempora";
    inherit version;
    sha256 = "9ea980c63be54f83d2a466fccc6eeef96a409f74c5034764fb328b0d43247e96";
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
