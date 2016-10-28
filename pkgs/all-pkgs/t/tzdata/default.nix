{ stdenv
, fetchurl
}:

let
  version = "2016h";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      sha256 = "da1b74fc2dec2ce8b64948dafb0bfc2f923c830d421a7ae4d016226135697a64";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      sha256 = "30e62f0b86a78fb020d378b950930da023ca31b1a58f08d8fb2066627c4d6566";
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
