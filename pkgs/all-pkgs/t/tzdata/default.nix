{ stdenv
, fetchurl
}:

let
  version = "2018c";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      multihash = "Qmeb9VPZNFWfoFzqm1zyX5jthZFKggRZVNQRiyLPoWyqRf";
      sha256 = "2825c3e4b7ef520f24d393bcc02942f9762ffd3e7fc9b23850789ed8f22933f6";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      multihash = "QmbdEmGRXxooAhbikTiGaLtkgwUrv4ok1JPhyhdwEoyuAa";
      sha256 = "31fa7fc0f94a6ff2d6bc878c0a35e8ab8b5aa0e8b01445a1d4a8f14777d0e665";
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
