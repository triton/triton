{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "autoconf-archive-2017.03.21";

  src = fetchurl {
    url = "mirror://gnu/autoconf-archive/${name}.tar.xz";
    hashOutput = false;
    sha256 = "386ad455f12bdeb3a7d19280441a5ab77355142349200ff11040a8d9d455d765";
  };

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      # Peter Simons
      pgpKeyFingerprint = "1A4F 63A1 3A46 49B6 32F6  5EE1 41BC 28FE 9908 9D72";
    };
  };

  meta = with stdenv.lib; {
    description = "Archive of autoconf m4 macros";
    homepage = http://www.gnu.org/software/autoconf-archive/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = autoconf.meta.platforms;
  };
}
