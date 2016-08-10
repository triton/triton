{ stdenv
, fetchurl

, krb5_lib
}:

stdenv.mkDerivation rec {
  name = "libtirpc-1.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/libtirpc/${name}.tar.bz2";
    sha256 = "17mqrdgsgp9m92pmq7bvr119svdg753prqqxmg4cnz5y657rfmji";
  };

  propagatedBuildInputs = [
    krb5_lib
  ];

  meta = with stdenv.lib; {
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
