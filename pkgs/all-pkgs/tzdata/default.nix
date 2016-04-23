{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "tzdata-${version}";
  version = "2016d";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      sha256 = "d9554dfba0efd76053582bd89e8c7036ef12eee14fdd506675b08a5b59f0a1b4";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      sha256 = "a8f33d6f87aef7e109e4769fc7f6e63637d52d07ddf6440a1a50df3d9a34e0ca";
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
