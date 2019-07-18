{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip

, idna
}:

let
  version = "1.16.0";
in
buildPythonPackage {
  name = "dnspython-${version}";

  src = fetchPyPi {
    package = "dnspython";
    type = ".zip";
    inherit version;
    sha256 = "36c5e8e38d4369a08b6780b7f27d790a292b2b08eea01607865bf0936c558e01";
  };

  nativeBuildInputs = [
    unzip
  ];

  propagatedBuiltInputs = [
    #ecdsa
    idna
    #pycryptodome
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
