{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cffi
, six
}:

let
  version = "3.1.7";
in
buildPythonPackage rec {
  name = "bcrypt-${version}";

  src = fetchPyPi {
    package = "bcrypt";
    inherit version;
    sha256 = "0b0069c752ec14172c5f78208f1863d7ad6755a6fae6fe76ec2c80d13be41e42";
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
