{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cffi
, six
}:

let
  version = "3.1.4";
in
buildPythonPackage rec {
  name = "bcrypt-${version}";

  src = fetchPyPi {
    package = "bcrypt";
    inherit version;
    sha256 = "67ed1a374c9155ec0840214ce804616de49c3df9c5bc66740687c1c9b1cd9e8d";
  };

  propagatedBuildInputs = [
    cffi
    six
  ];

  meta = with lib; {
    description = "Modern password hashing";
    homepage = https://github.com/pyca/bcrypt/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
