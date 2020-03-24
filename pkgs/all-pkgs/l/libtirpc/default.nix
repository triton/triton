{ stdenv
, fetchurl
, lib

, krb5_lib
}:

let
  version = "1.2.5";
in
stdenv.mkDerivation rec {
  name = "libtirpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libtirpc/libtirpc/${version}/${name}.tar.bz2";
    sha256 = "f3b6350c7e9c3cd9c58fc7a5e5f8e6be469cc571bb5eb31eb9790b3e675186ca";
  };

  propagatedBuildInputs = [
    krb5_lib
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=c99"  # Breaks libraries linking against this one using >c99.
  ];

  meta = with lib; {
    homepage = "http://sourceforge.net/projects/libtirpc/";
    description = "The transport-independent Sun RPC implementation (TI-RPC)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
