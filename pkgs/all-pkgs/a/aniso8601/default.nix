{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-dateutil
}:

let
  version = "4.1.0";
in
buildPythonPackage rec {
  name = "aniso8601-${version}";

  src = fetchPyPi {
    package = "aniso8601";
    inherit version;
    sha256 = "03c0ffeeb04edeca1ed59684cc6836dc377f58e52e315dc7be3af879909889f4";
  };

  propagatedBuildInputs = [
    python-dateutil
  ];

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
