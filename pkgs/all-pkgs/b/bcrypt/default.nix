{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cffi
, six
}:

let
  version = "3.1.6";
in
buildPythonPackage rec {
  name = "bcrypt-${version}";

  src = fetchPyPi {
    package = "bcrypt";
    inherit version;
    sha256 = "44636759d222baa62806bbceb20e96f75a015a6381690d1bc2eda91c01ec02ea";
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
