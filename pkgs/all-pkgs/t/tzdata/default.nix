{ stdenv
, fetchurl
, lzip
}:

let
  version = "2018i";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  src = fetchurl {
    url = "https://data.iana.org/time-zones/releases/tzdb-${version}.tar.lz";
    multihash = "QmUNfBc1dR3uPLWWXF8dg3TX9WuqeMBQ3WDhuikBoa56fu";
    hashOutput = false;
    sha256 = "1b7f91de728295d6363791cc728e4ea18af8493e07d947a6c2f217751294016a";
  };

  nativeBuildInputs = [
    lzip
  ];

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$out"
      "USRDIR="
    )
  '';

  postInstall = ''
    test -e "$out/share/zoneinfo-posix"
    ln -sv ../zoneinfo-posix "$out"/share/zoneinfo/posix
    test -e "$out/share/zoneinfo-leaps"
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/leaps
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/right
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "7E37 92A9 D8AC F7D6 33BC  1588 ED97 E90E 62AA 7E34";
      };
    };
  };

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
