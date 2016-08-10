{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gnum4

, gmp
}:

stdenv.mkDerivation rec {
  name = "nettle-3.2";

  src = fetchurl {
    url = "mirror://gnu/nettle/${name}.tar.gz";
    sha256 = "15wxhk52yc62rx0pddmry66hqm6z5brrrkx4npd3wh9nybg86hpa";
  };

  nativeBuildInputs = [
    # FIXME: remove once CVE is patched upstream
    autoreconfHook
    gnum4
  ];

  buildInputs = [
    gmp
  ];

  patches = [
    (fetchTritonPatch {
      rev = "553ec8a8988737c3dcacaa987746db09cca006a2";
      file = "nettle/nettle-3.2-CVE-2016-6489.patch";
      sha256 = "0bc6f90da2e682ebdfe1444ee83a591c4a47ba9ef70cfa955530a626e4f5888d";
    })
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Cryptographic library";
    homepage = http://www.lysator.liu.se/~nisse/nettle/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
