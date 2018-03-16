{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "autoconf-archive-2018.03.13";

  src = fetchurl {
    url = "mirror://gnu/autoconf-archive/${name}.tar.xz";
    hashOutput = false;
    sha256 = "6175f90d9fa64c4d939bdbb3e8511ae0ee2134863a2c7bf8d9733819efa6e159";
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
