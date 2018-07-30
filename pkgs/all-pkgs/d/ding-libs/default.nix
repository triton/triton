{ stdenv
, fetchurl
, lib

, ldb
, popt
, talloc
, tdb
, tevent
}:

stdenv.mkDerivation rec {
  name = "ding-libs-0.6.1";

  src = fetchurl {
    url = "https://releases.pagure.org/SSSD/ding-libs/${name}.tar.gz";
    multihash = "QmW2nGK5yMh6tshJjQQqyTcwEDDqsxdqWm7HXqq1HdpZn9";
    hashOutput = false;
    sha256 = "a319a327deb81f2dfab9ce4a4926e80e1dac5dcfc89f4c7e548cec2645af27c1";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "E4E3 6675 8CA0 716A AB80  4867 1EC6 AB75 32E7 BC25"
        "16F2 4229 488E 7360 4895  2737 BA88 000F E639 8272"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "'Ding is not GLib' assorted utility libraries";
    homepage = https://pagure.io/SSSD/ding-libs;
    license = with licenses; [
      gpl3
      lgpl3
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
