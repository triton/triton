{ stdenv
, fetchurl
}:

let
  version = "2018d";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      multihash = "QmZRu5Zhc14rCG3Ykv29b1DPcVNwiLmzMWWx517KpYsdds";
      sha256 = "5106eddceb5f1ae3a91dbd3960e1b8b11ba0dc08579a31cf0724a7691b10c054";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      multihash = "QmW9EqtCXZvW4Gh8FefYJdJRLRemGzLbQngdT4iVHAoSid";
      sha256 = "7de44e85baad748d217e3fd60706f599f9aec68bce6356b163f52b0dbd40a8d9";
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
