{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, swig

, pcsc-lite_lib
}:

let
  version = "1.9.6";
in
buildPythonPackage {
  name = "pyscard-${version}";

  src = fetchPyPi {
    package = "pyscard";
    inherit version;
    sha256 = "6e28143c623e2b34200d2fa9178dbc80a39b9c068b693b2e6527cdae784c6c12";
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
