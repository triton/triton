{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "tzdata-${version}";
  version = "2016b";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      sha256 = "6392091d92556a32de488ea06a055c51bc46b7d8046c8a677f0ccfe286b3dbdc";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      sha256 = "e935c4fe78b5c5da3791f58f3ab7f07fb059a7c71d6b62b69ef345211ae5dfa7";
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
