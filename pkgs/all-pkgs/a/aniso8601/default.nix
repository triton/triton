{ stdenv
, buildPythonPackage
, fetchPyPi

, python-dateutil
}:

let
  version = "1.1.0";
in
buildPythonPackage rec {
  name = "aniso8601-${version}";

  src = fetchPyPi {
    package = "aniso8601";
    inherit version;
    sha256 = "4fc462db59811f541bc25d865b86367153d8ce773ae75b16d54e2e1cd393b5cc";
  };

  propagatedBuildInputs = [
    python-dateutil
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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
