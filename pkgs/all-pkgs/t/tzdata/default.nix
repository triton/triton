{ stdenv
, fetchurl
}:

let
  version = "2017c";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      multihash = "Qme6gAJM5Yjms9sZZqCoWf1knaxhMCUifVHrkQFXdDZVC2";
      sha256 = "d6543f92a929826318e2f44ff3a7611ce5f565a43e10250b42599d0ba4cbd90b";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      multihash = "QmYTF7hvVbyNefJHtv8z4vNyoKXLiF3nV6Gtw4Jc8oU6xH";
      sha256 = "81e8b4bc23e60906640c266bbff3789661e22f0fa29fe61b96ec7c2816c079b7";
    })
  ];

  srcRoot = ".";

  preUnpack = ''
    mkdir src
    cd src
  '';

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$out"
      "TZDIR=$out/share/zoneinfo"
      "MANDIR=$TMPDIR/share/man"
      "LIBDIR=$TMPDIR/lib"
      "ETCDIR=$TMPDIR/bin"
    )
  '';

  postInstall = ''
    test -e "$out/share/zoneinfo-posix"
    ln -sv ../zoneinfo-posix "$out"/share/zoneinfo/posix
    test -e "$out/share/zoneinfo-leaps"
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/leaps
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/right
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
