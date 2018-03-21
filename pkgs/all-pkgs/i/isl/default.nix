{ stdenv
, fetchurl
, lib

, gmp
}:

stdenv.mkDerivation rec {
  name = "isl-0.19";

  src = fetchurl {
    url = "http://isl.gforge.inria.fr/${name}.tar.xz";
    multihash = "QmUmMWqKbbMEPdGQc4B8HQEHRprtbAHKTdroXpCZBH69WH";
    sha256 = "6d6c1aa00e2a6dfc509fa46d9a9dbe93af0c451e196a670577a148feecf6b8a5";
  };

  buildInputs = [
    gmp
  ];

  meta = with lib; {
    homepage = http://www.kotnet.org/~skimo/isl/;
    description = "A library for manipulating sets and relations of integer points bounded by linear constraints";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
