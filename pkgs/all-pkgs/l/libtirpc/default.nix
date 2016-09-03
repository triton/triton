{ stdenv
, fetchurl

, krb5_lib
}:

let
  version = "1.0.1";
in
stdenv.mkDerivation rec {
  name = "libtirpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libtirpc/libtirpc/${version}/${name}.tar.bz2";
    multihash = "QmNnzPhLJsDQy7qencHjxSopwrEX5VmaPtHPP7jtChPg5d";
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
