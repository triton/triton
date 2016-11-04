{ stdenv
, fetchurl
}:

let
  version = "2016i";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      multihash = "QmXYuPkEKfTuRmR4nSSLxbBmUY8JiyuT6fVEiGK18mtSHV";
      sha256 = "b6966ec982ef64fe48cebec437096b4f57f4287519ed32dde59c86d3a1853845";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      multihash = "QmdK8UYTj5V3woYWMPgkWHKxZKt2kuF6QPhQw2hUH15wwe";
      sha256 = "411e8adcb6288b17d6c2624fde65e7d82654ca69b813ae121504ff66f0cfba7b";
    })
  ];

  sourceRoot = ".";

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$out"
      "TZDIR=$out/share/zoneinfo"
      "MANDIR=$TMPDIR/share/man"
      "LIBDIR=$TMPDIR/lib"
      "ETCDIR=$TMPDIR/bin"
    )
  '';

  meta = with stdenv.lib; {
    homepage = http://www.iana.org/time-zones;
    description = "Database of current and historical time zones";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
