{ stdenv
, fetchurl
, lib

, krb5_lib
}:

let
  version = "1.2.6";
in
stdenv.mkDerivation rec {
  name = "libtirpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libtirpc/libtirpc/${version}/${name}.tar.bz2";
    sha256 = "4278e9a5181d5af9cd7885322fdecebc444f9a3da87c526e7d47f7a12a37d1cc";
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
