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
  name = "ding-libs-0.6.0";

  src = fetchurl {
    url = "https://releases.pagure.org/SSSD/ding-libs/${name}.tar.gz";
    hashOutput = false;
    sha256 = "764a211f40cbcf2c9a613fc7ce0d77799d5ee469221b8b6739972e76f09e9fad";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "E4E3 6675 8CA0 716A AB80  4867 1EC6 AB75 32E7 BC25";
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
