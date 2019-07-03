{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, swig

, pcsc-lite_lib
}:

let
  version = "1.9.8";
in
buildPythonPackage {
  name = "pyscard-${version}";

  src = fetchPyPi {
    package = "pyscard";
    inherit version;
    sha256 = "f59dc7ee467b210094e64c923e1c7f5e8e9501a672fc0c8f2cd958153e00d095";
  };

  nativeBuildInputs = [
    swig
  ];

  postPatch = ''
    grep -q '"libpcsclite.so.1"' smartcard/scard/winscarddll.c
    sed -i 's,"libpcsclite.so.1","${pcsc-lite_lib}/lib/libpcsclite.so.1",g' \
      smartcard/scard/winscarddll.c
  '';

  NIX_CFLAGS_COMPILE = "-I${pcsc-lite_lib}/include/PCSC";

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
