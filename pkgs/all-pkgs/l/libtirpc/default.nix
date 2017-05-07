{ stdenv
, fetchTritonPatch
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

  patches = [
    (fetchTritonPatch {
      rev = "d6fa7f49c0b35ca8b9015226bdbbecc45c9f0ac4";
      file = "l/libtirpc/add-missing-rwlocks.patch";
      sha256 = "8bcdbd700ec6f8b5f87881251f9851174df233975d95a8dfdf7359f057fb3b80";
    })
    (fetchTritonPatch {
      rev = "d6fa7f49c0b35ca8b9015226bdbbecc45c9f0ac4";
      file = "l/libtirpc/CVE-2017-8879.patch";
      sha256 = "091d3ff2b53a3ef9b20c61af19192434f652e528070fd57c706bce2988de0279";
    })
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
