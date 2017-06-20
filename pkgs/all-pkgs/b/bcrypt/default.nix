{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cffi
, six
}:

let
  version = "3.1.3";
in
buildPythonPackage rec {
  name = "bcrypt-${version}";

  src = fetchPyPi {
    package = "bcrypt";
    inherit version;
    sha256 = "6645c8d0ad845308de3eb9be98b6fd22a46ec5412bfc664a423e411cdd8f5488";
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
