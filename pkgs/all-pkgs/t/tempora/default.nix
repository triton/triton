{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
, setuptools-scm
, six
}:

let
  version = "1.13";
in
buildPythonPackage rec {
  name = "tempora-${version}";

  src = fetchPyPi {
    package = "tempora";
    inherit version;
    sha256 = "4848df474c9d7ad9515fbeaadc88e48843176b4b90393652156ccff613bcaeb1";
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
