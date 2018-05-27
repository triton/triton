{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-dateutil
}:

let
  version = "3.0.0";
in
buildPythonPackage rec {
  name = "aniso8601-${version}";

  src = fetchPyPi {
    package = "aniso8601";
    inherit version;
    sha256 = "7cf068e7aec00edeb21879c2bbda048656c34d281e133a77425be03b352122d8";
  };

  propagatedBuildInputs = [
    python-dateutil
  ];

  doCheck = true;

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
