{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "tzdata-${version}";
  version = "2016f";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      sha256 = "ed8c951008d12f1db55a11e96fc055718c6571233327d9de16a7f8475e2502b0";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      sha256 = "72325f384490a310eeb2ea0fab7e6f011a5be19adab2ff9d83bf9d1993b066ed";
    })
  ];

  sourceRoot = ".";

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$out"
      "TZDIR=$out/share/zoneinfo"
      "ETCDIR=$TMPDIR/etc"
      "LIBDIR=$out/lib"
      "MANDIR=$TMPDIR/man"
      "AWK=awk"
      "CFLAGS=-DHAVE_LINK=0"
    )
  '';

  postInstall = ''
    rm $out/share/zoneinfo-posix
    ln -s . $out/share/zoneinfo/posix
    mv $out/share/zoneinfo-leaps $out/share/zoneinfo/right

    mkdir -p "$out/include"
    cp tzfile.h "$out/include/tzfile.h"
  '';

  preferLocalBuild = true;

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
