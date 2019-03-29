{ stdenv
, fetchurl
, lzip
}:

let
  version = "2019a";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  src = fetchurl {
    url = "https://data.iana.org/time-zones/releases/tzdb-${version}.tar.lz";
    multihash = "QmZcwNYajuMvvcRS3q9G19uWUZ3M88gjHuNR2HxLqLk31Y";
    hashOutput = false;
    sha256 = "16d10794dd8de8eb21abbf21e74020b5e1b0227ea1f094299b0b4467954eecc7";
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
