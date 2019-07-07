{ stdenv
, fetchurl
, lzip
}:

let
  version = "2019b";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  src = fetchurl {
    url = "https://data.iana.org/time-zones/releases/tzdb-${version}.tar.lz";
    multihash = "QmfGfJ6Gz1dywdpACqWNL2m8Jvs5Q9P3tyw6tn6NbuFaAi";
    hashOutput = false;
    sha256 = "180adb8a6d9653a4892b9b1bf59ed0290a9fbfd3755f2f116cd46f2084ab02ef";
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
