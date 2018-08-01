{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, swig

, pcsc-lite_lib
}:

let
  version = "1.9.7";
in
buildPythonPackage {
  name = "pyscard-${version}";

  src = fetchPyPi {
    package = "pyscard";
    inherit version;
    sha256 = "412c74c83e7401566e9d3d7b8b5ca965e74582a1f33179b3c1fabf1da73ebf80";
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
