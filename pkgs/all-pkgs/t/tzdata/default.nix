{ stdenv
, fetchurl
, lzip
}:

let
  version = "2019c";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  src = fetchurl {
    url = "https://data.iana.org/time-zones/releases/tzdb-${version}.tar.lz";
    multihash = "QmS4DZimoEpdvritSwFZ3pHqD3zxeNaqtL6nNZFb5BD6G9";
    hashOutput = false;
    sha256 = "0f9ebf1d04c21d95f8ca2371f342133503388d215e5e2599ae6213b4aeeb3118";
  };

  nativeBuildInputs = [
    lzip
  ];

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$bin"
      "USRDIR="
      "TZDIR=$data/share/zoneinfo"
    )
  '';

  postInstall = ''
    ln -srv "$data"/share/zoneinfo-posix "$data"/share/zoneinfo/posix
    ln -srv "$data"/share/zoneinfo-leaps "$data"/share/zoneinfo/leaps
    ln -srv "$data"/share/zoneinfo-leaps "$data"/share/zoneinfo/right
  '';

  postFixup = ''
    rm -rv "$bin"/{lib,share}
  '';

  outputs = [
    "bin"
    "data"
    "man"
  ];

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
