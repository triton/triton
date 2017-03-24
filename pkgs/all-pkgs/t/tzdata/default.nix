{ stdenv
, fetchurl
}:

let
  version = "2017b";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      multihash = "QmXo1B5cCHmwprWHSRb8QpDNM9ShfaXoH3himRHg4CWvHw";
      sha256 = "f8242a522ea3496b0ce4ff4f2e75a049178da21001a08b8e666d8cbe07d18086";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      multihash = "QmUFQbi97RqtDruxCr5peP3FxekXbLUaxHXkBBAsxq5tqs";
      sha256 = "4d1735bb54e22b8d7443d4d1f1a13d007ae11be79a35e51f8e8322fb8e292d40";
    })
  ];

  sourceRoot = ".";

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
